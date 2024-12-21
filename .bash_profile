#
# ~/.bash_profile
#

declare -A commands_vars=(
  ["fzf"]="HAS_FZF"
  ["zoxide"]="HAS_ZOXIDE"
  ["thefuck"]="HAS_THEFUCK"
  ["win32yank.exe"]="HAS_WIN32YANK"
  ["nala"]="HAS_NALA"
  ["lsd"]="HAS_LSD"
  ["eza"]="HAS_EZA"
  ["trash-put"]="HAS_TRASH_PUT"
  ["bat"]="HAS_BAT"
  ["dircolors"]="HAS_DIRCOLORS"
)

for cmd in "${!commands_vars[@]}"; do
  if command -v "$cmd" >/dev/null; then
    declare "${commands_vars[$cmd]}=1"
  else
    declare "${commands_vars[$cmd]}=0"
  fi
done

unset commands_vars

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ${HOME}/.init_profile ]] && . ${HOME}/.init_profile
