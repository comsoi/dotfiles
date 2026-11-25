// 键位文档的唯一装配点。一个文件里做两件事：
//   1) 从 keybindings/{keys,key_tables,mouse}.lua 解析每条绑定的层级 / 键位 / 说明注释；
//   2) 按下面的 GROUPS 表（分组 + 排版）生成 / 校验 docs/keymap.html 里的 B 数据。
//
// 分工：**说明文字住 Lua**（每条绑定的紧邻注释），**分组与排版住这里**（GROUPS）。
//   * 单成员的组：行文案直接取那条绑定的 Lua 注释（没有注释就报错）；
//   * 多成员的合并行：行文案取 GROUPS 的 text（逐条注释拼不出合并后的句子）。
//
// 用法：
//   node docs/keymap_check.mjs          # 校验：覆盖齐不齐 + 文件里的 B 是否最新；有漂移退出码 1
//   node docs/keymap_check.mjs --write  # 按 GROUPS + Lua 重新生成 keymap.html 的 B
//   node docs/keymap_check.mjs --dump   # 打印解析到的全部绑定（调试 GROUPS 用）
import { readFileSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";

const ROOT = `${homedir()}/.config/wezterm`;
const MODE = process.argv.includes("--write") ? "write" : process.argv.includes("--dump") ? "dump" : "check";

// ───────────────────────── Lua 源解析 ─────────────────────────
// 取 `header` 里那个 `{` 之后、与之配对的大括号之内的正文（跳过注释与字符串里的括号）
function tableBody(text, header) {
  const i = text.indexOf(header);
  if (i < 0) throw new Error(`找不到 ${header}`);
  const open = text.indexOf("{", i + header.length - 1);
  let depth = 0;
  let inStr = false;
  let esc = false;
  for (let k = open; k < text.length; k++) {
    const c = text[k];
    if (inStr) {
      if (esc) esc = false;
      else if (c === "\\") esc = true;
      else if (c === '"') inStr = false;
      continue;
    }
    if (c === '"') { inStr = true; continue; }
    if (c === "-" && text[k + 1] === "-") {
      let e = text.indexOf("\n", k);
      if (e < 0) e = text.length;
      k = e - 1;
      continue;
    }
    if (c === "{") depth++;
    else if (c === "}") {
      depth--;
      if (depth === 0) return text.slice(open + 1, k);
    }
  }
  throw new Error(`${header} 的花括号不配对`);
}

const unescapeLua = (s) => s.replace(/\\\\/g, "\\");

// 一条 { key=..., mods=... } / passthrough_or_xxx("MODS", "key", ...)
function parseEntry(chunk) {
  const helper = chunk.match(/passthrough_or_(?:callback|action)\s*\(\s*"([^"]*)"\s*,\s*"([^"]*)"/);
  if (helper) return { mods: helper[1], key: unescapeLua(helper[2]) };
  const k = chunk.match(/\bkey\s*=\s*"([^"]*)"/);
  if (!k) return null;
  const m = chunk.match(/\bmods\s*=\s*"([^"]*)"/);
  return { key: unescapeLua(k[1]), mods: m ? m[1] : "" };
}

// 遍历表体，按顶层逗号切条目；紧邻其上的注释块（空行会切断）作为 desc。
// 分隔线一类的注释（含 >=4 个连续 - 或 ──）视作章节标题，不进 desc。
function lexEntries(body) {
  const out = [];
  let depth = 0;
  let buf = "";
  let pending = [];
  let inStr = false;
  let esc = false;
  const finish = () => {
    const e = parseEntry(buf);
    if (e) {
      e.desc = pending.join(" ").trim();
      out.push(e);
    }
    pending = [];
    buf = "";
  };
  const lines = body.split("\n");
  for (const line of lines) {
    const t = line.trim();
    if (depth === 0 && t === "") { pending = []; continue; }
    if (t.startsWith("--")) {
      const text = t.slice(2).trim();
      if (depth === 0 && text && !/-{4,}|─{2,}/.test(text)) pending.push(text);
      continue;
    }
    for (let k = 0; k < line.length; k++) {
      const c = line[k];
      if (inStr) {
        buf += c;
        if (esc) esc = false;
        else if (c === "\\") esc = true;
        else if (c === '"') inStr = false;
        continue;
      }
      if (c === '"') { inStr = true; buf += c; continue; }
      if (c === "-" && line[k + 1] === "-") break; // 行内注释
      if (c === "{" || c === "(" || c === "[") depth++;
      else if (c === "}" || c === ")" || c === "]") depth--;
      if (c === "," && depth === 0) {
        buf += c;
        finish();
        continue;
      }
      buf += c;
    }
    buf += "\n";
  }
  finish();
  return out;
}

// mods -> 层 id（与 keymap.html 的 LAYERS 对应）
function layerOf(mods) {
  const t = new Set((mods || "").split("|").filter(Boolean));
  if (t.has("LEADER")) {
    if (t.has("CTRL")) return "cleader";
    if (t.has("SHIFT")) return "sleader";
    return "leader";
  }
  if (t.has("ALT") && t.has("CTRL")) return "ctrlalt";
  if (t.has("ALT")) return "alt";
  return "global";
}

// key 名 -> keymap.html ROWS 里的网格 id
const KEY2GRID = {
  LeftArrow: "left", RightArrow: "right", UpArrow: "up", DownArrow: "down",
  PageUp: "pgup", PageDown: "pgdn", Home: "home", End: "end",
  Escape: "escape", Enter: "enter", Tab: "tab", Space: "space",
  Backspace: "bksp", Delete: "del", F11: "f11", F12: "f12",
  "-": "minus", "=": "equal", "\\": "backslash", "[": "lbracket", "]": "rbracket",
  ";": "semicolon", "'": "quote", ",": "comma", ".": "period", "/": "slash", "`": "backtick",
};
const SHIFT_SYMBOL = {
  "!": "1", "@": "2", "#": "3", $: "4", "%": "5", "^": "6", "&": "7", "*": "8",
  "(": "9", ")": "0", _: "minus", "+": "equal", "{": "lbracket", "}": "rbracket",
  "|": "backslash", ":": "semicolon", '"': "quote", "~": "backtick",
  "<": "comma", ">": "period", "?": "slash",
};
function gridOf(key) {
  if (!key) return null;
  if (KEY2GRID[key]) return KEY2GRID[key];
  if (SHIFT_SYMBOL[key]) return SHIFT_SYMBOL[key];
  if (/^[A-Za-z]$/.test(key)) return key.toLowerCase();
  if (/^[0-9]$/.test(key)) return key;
  return null;
}

const normMods = (m) => (m || "").split("|").filter(Boolean).sort().join("|");
const read = (rel) => readFileSync(`${ROOT}/${rel}`, "utf8");

// 解析三个 Lua 文件 -> [{ layer, mods, key, grid, desc }]（含 M.apply 的 1-9 数字键）
function collectBindings() {
  const out = [];
  const keysRaw = read("keybindings/keys.lua");
  for (const e of lexEntries(tableBody(keysRaw, "M.keys = {"))) {
    out.push({ ...e, layer: layerOf(e.mods), grid: gridOf(e.key) });
  }
  if (/for\s+i\s*=\s*1\s*,\s*9\s+do/.test(keysRaw)) {
    for (let i = 1; i <= 9; i++) {
      for (const mods of ["LEADER", "ALT|CTRL", "ALT"]) {
        out.push({ mods, key: String(i), desc: "", layer: layerOf(mods), grid: String(i) });
      }
    }
  }
  for (const e of lexEntries(tableBody(tableBody(read("keybindings/key_tables.lua"), "M.key_tables = {"), "copy_mode = {"))) {
    out.push({ ...e, layer: "copy", grid: gridOf(e.key) });
  }
  return out;
}

const bindings = collectBindings();
const idOf = (layer, mods, key) => `${layer}|${normMods(mods)}|${key}`;
const byId = new Map(bindings.map((b) => [idOf(b.layer, b.mods, b.key), b]));

if (MODE === "dump") {
  for (const b of bindings) {
    console.log(`${b.layer.padEnd(8)} ${(b.mods || "-").padEnd(17)} ${String(b.key).padEnd(10)} ${String(b.grid ?? "?").padEnd(9)} ${b.desc}`);
  }
  process.exit(0);
}

// ───────────────────────── 分组表（排版）─────────────────────────
// l: 层   k: 显示用键名   members: [mods, key]（对齐 Lua）   text: 合并行文案   n: 备注
const R = (l, k, members, extra = {}) => ({ l, k, members: members.map(([m, key]) => [m, key]), ...extra });
const GROUPS = [
  // ── 全局 ──
  R("global", "Ctrl+Shift+V", [["SHIFT|CTRL", "V"]]),
  R("global", "Ctrl+Shift+S", [["SHIFT|CTRL", "S"]]),
  R("global", "Ctrl+Shift+C", [["SHIFT|CTRL", "C"]]),
  R("global", "Ctrl+Shift+F", [["SHIFT|CTRL", "F"]]),
  R("global", "Ctrl+Shift+P", [["SHIFT|CTRL", "P"]]),
  R("global", "Ctrl+Shift+Space", [["SHIFT|CTRL", "Space"]]),
  R("global", "Ctrl+Shift++ / _ / )", [["SHIFT|CTRL", "+"], ["SHIFT|CTRL", "_"], ["SHIFT|CTRL", ")"]], { text: "字号 + / − / 重置（Ctrl+滚轮 同效）" }),
  R("global", "Ctrl+C", [["CTRL", "c"]]),
  R("global", "Ctrl+Shift+A", [["SHIFT|CTRL", "A"]]),
  R("global", "Ctrl+Shift+← / →", [["SHIFT|CTRL", "LeftArrow"], ["SHIFT|CTRL", "RightArrow"]], { text: "上一个 / 下一个 tab" }),
  R("global", "Ctrl+Shift+PageUp / PageDown", [["SHIFT|CTRL", "PageUp"], ["SHIFT|CTRL", "PageDown"], ["SHIFT", "PageUp"], ["SHIFT", "PageDown"]], { text: "整页滚动（Shift 单独为半页）" }),
  R("global", "Ctrl+Shift+K / J", [["SHIFT|CTRL", "K"], ["SHIFT|CTRL", "J"]], { text: "上 / 下滚 3 行" }),
  R("global", "Ctrl+Shift+↑ / ↓", [["SHIFT|CTRL", "UpArrow"], ["SHIFT|CTRL", "DownArrow"]], { text: "上 / 下滚 1 行" }),
  R("global", "Ctrl+Shift+Home / End", [["SHIFT|CTRL", "Home"], ["SHIFT|CTRL", "End"]], { text: "滚到顶 / 底" }),
  R("global", "Ctrl+Shift+Delete", [["CTRL|SHIFT", "Delete"]]),
  R("global", "Super+k", [["SUPER", "k"]]),
  R("global", "Ctrl+Shift+< / >", [["SHIFT|CTRL", "<"], ["SHIFT|CTRL", ">"]], { text: "向左 / 右移动 tab" }),
  R("global", "F11", [["", "F11"]]),
  R("global", "Ctrl+Shift+T", [["CTRL|SHIFT", "T"]]),
  R("global", "Ctrl+Shift+W", [["CTRL|SHIFT", "W"]]),
  R("global", "Ctrl+Shift+Enter", [["SHIFT|CTRL", "Enter"]]),
  R("global", "Ctrl+Tab / Ctrl+Shift+Tab", [["CTRL", "Tab"], ["SHIFT|CTRL", "Tab"]], { text: "下一个 / 上一个 tab：多 tab 时自己切；单 tab 时透传进 pane" }),
  R("global", "Shift+↑ / Shift+↓", [["SHIFT", "UpArrow"], ["SHIFT", "DownArrow"]], { text: "普通模式下的 prompt 跳转（ScrollToPrompt）" }),

  // ── Alt ──
  R("alt", "Alt+h / j / k / l", [["ALT", "h"], ["ALT", "j"], ["ALT", "k"], ["ALT", "l"]], { text: "mux/nvim 里透传；否则切 wezterm pane（左右到边界切 tab，且落到新 tab 里方向一致的那一侧）" }),
  R("alt", "Alt+[ / Alt+]", [["ALT", "["], ["ALT", "]"]], { text: "上一个 / 下一个 pane（同样先判断透传）" }),
  R("alt", "Alt+方向键", [["ALT", "LeftArrow"], ["ALT", "RightArrow"], ["ALT", "UpArrow"], ["ALT", "DownArrow"]], { text: "调整 pane 大小 5 格（在 mux/nvim 里交给内层）" }),
  R("alt", "Alt+n", [["ALT", "n"]]),
  R("alt", "Alt+0-9", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].map((d) => ["ALT", d]), { text: "切到第 N 个 tab（0 = 最后一个）" }),

  // ── Ctrl+Alt ──
  R("ctrlalt", "Ctrl+Alt+h / l", [["ALT|CTRL", "h"], ["ALT|CTRL", "l"]], { text: "pane-or-tab 左 / 右（直接执行）" }),
  R("ctrlalt", "Ctrl+Alt+j / k", [["ALT|CTRL", "j"], ["ALT|CTRL", "k"]], { text: "上 / 下 pane" }),
  R("ctrlalt", "Ctrl+Alt+[ / ]", [["ALT|CTRL", "["], ["ALT|CTRL", "]"]], { text: "上一个 / 下一个 tab" }),
  R("ctrlalt", "Ctrl+Alt+0-9", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].map((d) => ["ALT|CTRL", d]), { text: "切到第 N 个 tab（0 = 最后一个）" }),
  R("ctrlalt", "Ctrl+Alt+- / \\", [["ALT|CTRL", "-"], ["ALT|CTRL", "\\"]], { text: "纵向 / 横向分割" }),
  R("ctrlalt", "Ctrl+Alt+Enter", [["ALT|CTRL", "Enter"]]),
  R("ctrlalt", "Ctrl+Alt+Shift+{ / }", [["SHIFT|ALT|CTRL", "{"], ["SHIFT|ALT|CTRL", "}"]], { text: "向左 / 右移动 tab（另一组键）" }),
  R("ctrlalt", "Ctrl+Alt+Shift+C", [["SHIFT|ALT|CTRL", "C"]]),
  R("ctrlalt", "Ctrl+Alt+Shift+H J K L", [["SHIFT|ALT|CTRL", "H"], ["SHIFT|ALT|CTRL", "J"], ["SHIFT|ALT|CTRL", "K"], ["SHIFT|ALT|CTRL", "L"]], { text: "调整 pane 大小 10 格（不判断透传，直接调外层 wezterm）" }),

  // ── Leader ──
  R("leader", "Leader+h j k l / 方向键", [["LEADER", "h"], ["LEADER", "j"], ["LEADER", "k"], ["LEADER", "l"], ["LEADER", "UpArrow"], ["LEADER", "DownArrow"], ["LEADER", "LeftArrow"], ["LEADER", "RightArrow"]], { text: "pane-or-tab 移动，可连续按（进入 activate_pane 表）" }),
  R("leader", "Leader+o / O", [["LEADER", "o"], ["LEADER", "O"]], { text: "本 tab 内下一个 / 上一个 pane（不切 tab，与 Alt+[ ] 同；带 activate_pane 表）", n: "O = Shift+o；切 tab 用 Leader+n / p" }),
  R("leader", "Leader+Alt+o / O", [["ALT|LEADER", "o"], ["ALT|LEADER", "O"]], { text: "轮转 pane（RotatePanes 顺时针 / 逆时针）" }),
  R("leader", "Leader+s", [["LEADER", "s"]]),
  R("leader", "Leader+f", [["LEADER", "f"]]),
  R("leader", "Leader+x", [["LEADER", "x"]]),
  R("leader", "Leader+z", [["LEADER", "z"]]),
  R("leader", "Leader+e", [["LEADER", "e"]]),
  R("leader", "Leader+g", [["LEADER", "g"]]),
  R("leader", "Leader+c", [["LEADER", "c"]]),
  R("leader", "Leader+q", [["LEADER", "q"]]),
  R("leader", "Leader+n / p", [["LEADER", "n"], ["LEADER", "p"]], { text: "下一个 / 上一个 tab（进入 activate_tab 表）" }),
  R("leader", "Leader+0-9", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].map((d) => ["LEADER", d]), { text: "切到第 N 个 tab（0 = 最后一个）" }),
  R("leader", "Leader+- / \\", [["LEADER", "-"], ["LEADER", "\\"]], { text: "纵向 / 横向分割" }),
  R("leader", "Leader+Enter", [["LEADER", "Enter"]]),
  R("leader", "Leader+Space", [["LEADER", "Space"]]),
  R("leader", "Leader+`", [["LEADER", "`"]]),
  R("leader", "Leader+w", [["LEADER", "w"]]),
  R("leader", "Leader+i / d", [["LEADER", "i"], ["LEADER", "d"]], { text: "附接 / 分离 unix domain（≈ attach/detach）" }),
  R("leader", "Leader+.", [["LEADER", "."]]),
  R("leader", "Leader+,", [["LEADER", ","]]),
  R("leader", "Leader+Escape / /", [["LEADER", "Escape"], ["LEADER", "/"]], { text: "进入复制模式（Leader+[ 已不存在，改用 Ctrl+Leader+[）" }),
  R("leader", "Leader+v", [["LEADER", "v"]]),
  R("leader", "Leader+F12", [["LEADER", "F12"]]),

  // ── Shift+Leader ──
  R("sleader", "Shift+Leader+H J K L / 方向键", [["SHIFT|LEADER", "H"], ["SHIFT|LEADER", "J"], ["SHIFT|LEADER", "K"], ["SHIFT|LEADER", "L"], ["SHIFT|LEADER", "UpArrow"], ["SHIFT|LEADER", "DownArrow"], ["SHIFT|LEADER", "LeftArrow"], ["SHIFT|LEADER", "RightArrow"]], { text: "调整 pane 10 格，并进入 resize_pane 表（表内 1 格 / Shift 10 格）" }),
  R("sleader", "Shift+Leader+V", [["SHIFT|LEADER", "V"]]),
  R("sleader", "Shift+Leader+E", [["SHIFT|LEADER", "E"]]),
  R("sleader", "Shift+Leader+F", [["SHIFT|LEADER", "F"]]),
  R("sleader", "Shift+Leader+$", [["SHIFT|LEADER", "$"]]),
  R("sleader", "Shift+Leader+!", [["LEADER|SHIFT", "!"]]),
  R("sleader", "Shift+Leader+&", [["SHIFT|LEADER", "&"]]),
  R("sleader", "Shift+Leader+P / N", [["SHIFT|LEADER", "P"], ["SHIFT|LEADER", "N"]], { text: "向左 / 右移动 tab（进入 move_tab 表）" }),
  R("sleader", "Shift+Leader+S", [["SHIFT|LEADER", "S"]]),

  // ── Ctrl+Leader ──
  R("cleader", "Ctrl+Leader+a", [["CTRL|LEADER", "a"]]),
  R("cleader", "Ctrl+Shift+Leader+A", [["SHIFT|CTRL|LEADER", "A"]]),
  R("cleader", "Ctrl+Leader+r", [["CTRL|LEADER", "r"]]),
  R("cleader", "Ctrl+Shift+Leader+R", [["SHIFT|CTRL|LEADER", "R"]]),
  R("cleader", "Ctrl+Leader+[", [["CTRL|LEADER", "["]]),
  R("cleader", "Ctrl+Leader+o", [["CTRL|LEADER", "o"]]),
  R("cleader", "Ctrl+Leader+v", [["CTRL|LEADER", "v"]]),

  // ── 复制模式 ──
  R("copy", "h j k l / 方向键", [["NONE", "h"], ["NONE", "j"], ["NONE", "k"], ["NONE", "l"], ["NONE", "LeftArrow"], ["NONE", "RightArrow"], ["NONE", "UpArrow"], ["NONE", "DownArrow"]], { text: "移动光标" }),
  R("copy", "w b e / Ctrl+← →", [["NONE", "w"], ["NONE", "b"], ["NONE", "e"], ["CTRL", "LeftArrow"], ["CTRL", "RightArrow"]], { text: "按词移动" }),
  R("copy", "0 ^ $", [["NONE", "0"], ["SHIFT", "^"], ["SHIFT", "$"]], { text: "行首 / 首个非空 / 行尾" }),
  R("copy", "H M L", [["SHIFT", "H"], ["SHIFT", "M"], ["SHIFT", "L"]], { text: "视口 顶 / 中 / 底" }),
  R("copy", "g G", [["NONE", "g"], ["SHIFT", "G"]], { text: "scrollback 顶 / 底" }),
  R("copy", "Ctrl+u / Ctrl+d / Ctrl+b / Ctrl+f", [["CTRL", "u"], ["CTRL", "d"], ["CTRL", "b"], ["CTRL", "f"]], { text: "半页 / 整页滚动（u d 半页、b f 整页）" }),
  R("copy", "f t F T ; ,", [["NONE", "f"], ["NONE", "t"], ["SHIFT", "F"], ["SHIFT", "T"], ["NONE", ";"], ["NONE", ","]], { text: "字符跳转（vi 风格）" }),
  R("copy", "v / V / Ctrl+v / Space", [["NONE", "v"], ["SHIFT", "V"], ["CTRL", "v"], ["NONE", "Space"]], { text: "cell / line / block 选择（Space 也是 cell）" }),
  R("copy", "Tab / Shift+Tab", [["NONE", "Tab"], ["SHIFT", "Tab"]], { text: "下一个 / 上一个词（MoveForwardWord / MoveBackwardWord）" }),
  R("copy", "o / O", [["NONE", "o"], ["SHIFT", "O"]], { text: "跳到选区另一端" }),
  R("copy", "y", [["NONE", "y"]]),
  R("copy", "Ctrl+c / i / Escape", [["CTRL", "c"], ["NONE", "i"], ["NONE", "Escape"]], { text: "关闭复制模式：Esc 有选区先取消、否则回底退出；i / Ctrl+c 直接退出" }),
  R("copy", "Ctrl+e", [["CTRL", "e"]]),
  R("copy", "J K n p x z", [["NONE", "J"], ["NONE", "K"], ["NONE", "n"], ["NONE", "p"], ["NONE", "x"], ["NONE", "z"]], { text: "按 OSC133 语义区（输出块）跳转" }),
  R("copy", "Enter / PageUp / PageDown / Home / End", [["NONE", "Enter"], ["NONE", "PageUp"], ["NONE", "PageDown"], ["NONE", "Home"], ["NONE", "End"]], { text: "光标移动（Enter 到下一行行首）" }),

  // ── 鼠标（无网格键位）──
  R("mouse", "右键", [], { text: "有选区则复制，否则粘贴" }),
  R("mouse", "Ctrl+左键", [], { text: "打开光标下的链接" }),
  R("mouse", "左键抬起", [], { text: "不自动打开链接（默认行为被关闭）" }),
  R("mouse", "Ctrl+滚轮", [], { text: "放大 / 缩小字号" }),
  R("mouse", "左键四连击", [], { text: "按语义区（SemanticZone）选中" }),
];

// ───────────────────────── 生成 B ─────────────────────────
const problems = [];
function buildB() {
  return GROUPS.map((g) => {
    const grids = [...new Set(g.members.map(([, key]) => gridOf(key)).filter(Boolean))];
    let a;
    if (g.text != null) {
      a = g.text;
    } else {
      if (g.members.length !== 1) { problems.push(`组「${g.k}」有 ${g.members.length} 个成员，必须给 text`); a = ""; }
      const [m, key] = g.members[0];
      const b = byId.get(idOf(g.l, m, key));
      if (!b) { problems.push(`组「${g.k}」的成员 ${m} ${key} 不在 Lua 里`); a = ""; }
      else if (!b.desc) { problems.push(`绑定 ${m} ${key}（${g.k}）在 Lua 里没有说明注释`); a = ""; }
      else a = b.desc;
    }
    const row = { l: g.l, k: g.k };
    if (grids.length) row.g = grids.length === 1 ? grids[0] : grids;
    row.a = a;
    if (g.n) row.n = g.n;
    return row;
  });
}

const jstr = (s) => `"${String(s).replace(/\\/g, "\\\\").replace(/"/g, '\\"')}"`;
const rowSrc = (r) => {
  const parts = [`l:${jstr(r.l)}`, `k:${jstr(r.k)}`];
  if (r.g) parts.push(`g:${Array.isArray(r.g) ? "[" + r.g.map(jstr).join(",") + "]" : jstr(r.g)}`);
  parts.push(`a:${jstr(r.a)}`);
  if (r.n) parts.push(`n:${jstr(r.n)}`);
  return `  { ${parts.join(", ")} },`;
};

// ───────────────────────── keymap.html ─────────────────────────
const HTML_PATH = `${ROOT}/docs/keymap.html`;
const START = "/* gen:B:start";
const END = "/* gen:B:end */";

const html = readFileSync(HTML_PATH, "utf8");
const m = html.match(/<script>([\s\S]*?)<\/script>/);
if (!m) throw new Error("找不到 <script>");
let js = m[1];
js = js.replace(
  'document.getElementById("q").addEventListener("input", renderAll);',
  "globalThis.__B = B; globalThis.__ROWS = ROWS; globalThis.__LAYERS = LAYERS;"
);
function el() {
  return {
    tag: "div", children: [], innerHTML: "", textContent: "", dataset: {}, value: "",
    style: { setProperty() {} }, classList: { add() {}, remove() {} },
    appendChild(c) { this.children.push(c); return c; }, addEventListener() {},
    set onclick(f) { this._onclick = f; }, get onclick() { return this._onclick; },
  };
}
const store = {};
globalThis.document = { getElementById: (id) => (store[id] ||= el()), createElement: el };
await import("data:text/javascript," + encodeURIComponent(js));
const fileB = globalThis.__B, ROWS = globalThis.__ROWS, LAYERS = globalThis.__LAYERS;

if (MODE === "write") {
  const rows = buildB();
  if (problems.length) { console.log("无法生成:\n" + problems.join("\n")); process.exit(1); }
  const s = html.indexOf(START);
  const e = html.indexOf(END);
  if (s < 0 || e < 0) throw new Error(`keymap.html 里缺少 ${START} / ${END} 标记`);
  const header = "/* gen:B:start —— 由 docs/keymap_check.mjs 生成，勿手改；改 GROUPS 或 Lua 注释 */\n";
  const block = html.slice(0, s) + header + rows.map(rowSrc).join("\n") + "\n  " + END + html.slice(e + END.length);
  writeFileSync(HTML_PATH, block);
  console.log(`已写入 keymap.html（${rows.length} 行）`);
  process.exit(0);
}

// ───────────────────────── 校验 ─────────────────────────
const expected = buildB();
if (JSON.stringify(expected) !== JSON.stringify(fileB)) problems.push("keymap.html 的 B 与 GROUPS/Lua 不一致（跑 --write 重新生成）");

// 覆盖：每条 Lua 绑定必须恰好归入一个组
const seen = new Map();
for (const g of GROUPS) {
  for (const [mods, key] of g.members) {
    const id = idOf(g.l, mods, key);
    if (!byId.has(id)) { problems.push(`组「${g.k}」的成员 ${mods} ${key} 不在 Lua 里`); continue; }
    if (seen.has(id)) problems.push(`绑定 ${mods} ${key} 被多个组引用（${seen.get(id)} / ${g.k}）`);
    seen.set(id, g.k);
  }
}
for (const b of bindings) {
  if (!seen.has(idOf(b.layer, b.mods, b.key))) problems.push(`Lua 有、未归组: ${b.layer} ${b.mods} ${b.key}（${b.grid ?? "?"}）`);
}

// html 自身健全性
const gridIds = new Set(ROWS.flat().map((r) => r[1]).filter(Boolean));
const layerIds = new Set(LAYERS.map((l) => l.id));
const grids = (b) => (Array.isArray(b.g) ? b.g : b.g ? [b.g] : []);
for (const b of fileB) {
  if (!layerIds.has(b.l)) problems.push(`未知层: ${b.l} (${b.k})`);
  for (const g of grids(b)) if (!gridIds.has(g)) problems.push(`grid id 不存在: ${g} (${b.k})`);
}

console.log(`B 行数: ${fileB.length} · Lua 绑定: ${bindings.length} · 已归组: ${seen.size}`);
console.log(problems.length ? "问题:\n" + problems.join("\n") : "一致性检查通过 ✓");
process.exitCode = problems.length ? 1 : 0;
