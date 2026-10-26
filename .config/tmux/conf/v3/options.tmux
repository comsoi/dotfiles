# ==============================================================================
# v3 层：新选项（3.0+，由 tmux.conf 的版本闸门加载）
# ==============================================================================

# 新选项（带 -q，低于引入版本时静默跳过）：
#   allow-passthrough 3.3+（供其它 DCS 透传用，如终端内显示图片；OSC 1337 上报已移除）
#   extended-keys     3.2+
#   copy-command      3.2+
#   set-clipboard     2.6+
set -gq allow-passthrough on
set -sq extended-keys     on
set -sq copy-command      'wl-copy'
set -s  set-clipboard     on
set -g  mouse             on

# terminal-features 3.2+；-a 追加保留内置默认项（xterm* 等），
# 但 -a 对不存在的选项即使有 -q 也会报 invalid option，故用闸门包住
if-shell '[ -n "#{version}" ] && [ "$(printf "3.2\n%s\n" "#{version}" | sed -E "s/[^0-9.].*$//" | sort -V | head -n1)" = "3.2" ]' \
    'set -sa terminal-features "*:usstyle:strikethrough:256:RGB:sixel:hyperlinks:clipboard"'
