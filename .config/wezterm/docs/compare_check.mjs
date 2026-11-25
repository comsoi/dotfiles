// 校验 compare.html（wezterm / tmux / zellij 前缀层三边对照）。三件事：
//   1) 数据完整性 + 用最小 DOM 桩把页面脚本完整跑一遍（能抓渲染逻辑的运行时错误）；
//   2) 快照新鲜度：这份表是手工维护的（三边语义要人判断），头部「快照源」行记三个真实源的 sha8 ——
//      keybindings/keys.lua、~/.config/tmux/conf/keys/*.tmux、~/.config/zellij/config.kdl。
//      源改过而表没同步时报出该填的新值、退出码 1，否则表会一直 ✓ 通过却描述一个已经不存在的配置。
//      （旧版盯 docs/KEYMAPS.md；该文件已删，改为直接盯配置源。）
//   3) wezterm 列与 keys.lua 核对：w 列声称有 Leader+X 的必须真有，标「—」/「（已删）」的必须真没有。
//      Leader 键位取自 keymap_check.mjs --dump（Lua 解析的唯一实现，不在本文件复制一份）。
// 用法：node ~/.config/wezterm/docs/compare_check.mjs
import { readFileSync, readdirSync } from "node:fs";
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { homedir } from "node:os";

const HOME = homedir();
const ROOT = `${HOME}/.config/wezterm`;
const DOCS = `${ROOT}/docs`;

// ---- 数据完整性：把页面脚本完整跑一遍，再取 DATA / VERDICT ----
const html = readFileSync(`${DOCS}/compare.html`, "utf8");
const m = html.match(/<script>([\s\S]*?)<\/script>/);
if (!m) throw new Error("找不到 <script>");
const js = m[1] + "\nglobalThis.__DATA = DATA; globalThis.__VERDICT = VERDICT;\n";

const store = {};
function el() {
  return {
    value: "", checked: false, innerHTML: "", textContent: "",
    addEventListener() {},
    style: {},
  };
}
globalThis.document = { getElementById: (id) => (store[id] ||= el()) };

try {
  await import("data:text/javascript," + encodeURIComponent(js));
} catch (e) {
  console.log("页面脚本执行失败（渲染逻辑或数据有错）:\n  " + (e?.message ?? e));
  process.exit(1);
}
const DATA = globalThis.__DATA, VERDICT = globalThis.__VERDICT;
if (!Array.isArray(DATA) || !VERDICT) {
  console.log("页面里找不到 DATA / VERDICT（变量改名了？）");
  process.exit(1);
}

const rows = DATA.filter((r) => !r.group);
const problems = [];
for (const r of rows) {
  for (const k of ["k", "w", "t", "z", "v"]) {
    if (!r[k]) problems.push(`缺字段 ${k}: ${JSON.stringify(r.k || r)}`);
  }
  if (r.v && !(r.v in VERDICT)) problems.push(`未知判定: ${r.v} (${r.k})`);
}
const groups = DATA.filter((r) => r.group).length;
const counts = {};
for (const r of rows) counts[r.v] = (counts[r.v] || 0) + 1;

// ---- wezterm 列 vs keys.lua ----
// keymap_check.mjs --dump 的行格式：层 修饰键 键 …（修饰键用 | 连接）。
// 「纯前缀层」= LEADER / SHIFT|LEADER（裸键行核对它）；Ctrl+Leader 组合行另取一组。
let dump = "";
try {
  dump = execFileSync(process.execPath, [`${DOCS}/keymap_check.mjs`, "--dump"], { encoding: "utf8" });
} catch (e) {
  const detail = String(e?.stderr ?? "").split("\n").find((l) => l.startsWith("Error:")) ?? e?.message ?? e;
  problems.push(`keymap_check.mjs --dump 跑不动: ${detail}`);
}
const dumpRows = dump.split("\n").flatMap((line) => {
  const t = line.match(/^(\S+)\s+(\S+)\s+(\S+)\s/);
  return t ? [{ mods: t[2].split("|"), key: t[3] }] : [];
});
const prefixKeys = new Set(dumpRows.filter((r) => r.mods.includes("LEADER") && r.mods.every((t) => t === "LEADER" || t === "SHIFT")).map((r) => r.key));
const chordKeys = new Set(dumpRows.filter((r) => r.mods.includes("LEADER") && r.mods.includes("CTRL")).map((r) => r.key));

// 从 k 列提取该行声称的键：单字符键（空格 / 斜杠分隔多个）、0-9、几个具名键；
// Ctrl+Leader+<keys> 组合行单独处理；认不出的行（C-s、含其他 + 的写法）返回 null 跳过。
const NAMED = {
  Esc: ["Escape"], Enter: ["Enter"], Space: ["Space"], Tab: ["Tab"],
  F12: ["F12"], PageUp: ["PageUp"],
  方向键: ["UpArrow", "DownArrow", "LeftArrow", "RightArrow"],
};
const single = (t) => /^[\x21-\x7e]$/.test(t);
function claimOf(k) {
  const bare = k.replace(/（[^）]*）/g, "").trim();
  const keys = [];
  const chord = /^Ctrl\+Leader\+(.+)$/.exec(bare);
  if (chord) {
    for (const t of chord[1].split("/").map((s) => s.trim()).filter(Boolean)) {
      if (!single(t)) return null;
      keys.push(t);
    }
    return { keys, chord: true };
  }
  if (bare.includes("+")) return null;
  for (const t of bare.split(/[\s/]+/).filter(Boolean)) {
    if (t === "0-9") keys.push(..."0123456789");
    else if (NAMED[t]) keys.push(...NAMED[t]);
    else if (single(t)) keys.push(t);
    else return null;
  }
  return keys.length ? { keys, chord: false } : null;
}

let checkedRows = 0, checkedKeys = 0;
if (dump) {
  for (const r of rows) {
    const claim = claimOf(r.k);
    if (!claim) continue;
    const bound = claim.chord ? chordKeys : prefixKeys;
    const claimed = !/^(—|（已删）)/.test(r.w.trim());
    for (const key of claim.keys) {
      const what = (claim.chord ? "Ctrl+Leader+" : "Leader+") + key;
      if (claimed && !bound.has(key)) problems.push(`w 列声称有 ${what}（${r.k} 行），但 keys.lua 里没有`);
      if (!claimed && bound.has(key)) problems.push(`w 列标「—」但 keys.lua 里真有 ${what}（${r.k} 行）`);
      checkedKeys++;
    }
    checkedRows++;
  }
}

// ---- 快照新鲜度 ----
const sha8 = (s) => createHash("sha256").update(s).digest("hex").slice(0, 8);
let fresh = [];
try {
  const tmuxKeys = `${HOME}/.config/tmux/conf/keys`;
  const SOURCES = [
    ["wezterm", [`${ROOT}/keybindings/keys.lua`]],
    ["tmux", readdirSync(tmuxKeys).filter((f) => f.endsWith(".tmux")).sort().map((f) => `${tmuxKeys}/${f}`)],
    ["zellij", [`${HOME}/.config/zellij/config.kdl`]],
  ];
  fresh = SOURCES.map(([col, files]) => [col, sha8(files.map((f) => readFileSync(f)).join("\u0000"))]);
} catch (e) {
  problems.push(`读不到快照源: ${e?.message ?? e}`);
}
const recorded = Object.fromEntries(
  [...(html.match(/^\s*快照源:.*$/m)?.[0] ?? "").matchAll(/([\w.]+)=([0-9a-f]{8})/g)].map((x) => [x[1], x[2]])
);
for (const [col, now] of fresh) {
  if (recorded[col] !== now) problems.push(`快照过期: ${col} 记录=${recorded[col] ?? "缺失"} 现在=${now}`);
}
if (fresh.some(([col, now]) => recorded[col] !== now)) {
  console.log("先核对 / 同步三列内容，再把 html 头部的「快照源」行整行换成下面这行：");
  console.log("  快照源: " + fresh.map(([col, now]) => `${col}=${now}`).join(" "));
}

console.log(`行数: ${rows.length}（分组 ${groups}）`);
console.log(`判定分布: ${Object.entries(counts).map(([k, v]) => `${k}=${v}`).join(", ")}`);
if (dump) console.log(`Leader 核对: ${checkedRows} 行 / ${checkedKeys} 键（wezterm 列 vs keys.lua）`);
console.log(problems.length ? "问题:\n" + problems.join("\n") : "一致性检查通过 ✓");
// 有问题就非零退出：这样才能挂到 commit 钩子/CI 上，而不是只打印一行让人忽略
process.exitCode = problems.length ? 1 : 0;
