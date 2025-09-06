setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt PUSHD_SILENT
# setopt PUSHD_TO_HOME

DIRSTACKSIZE=20

alias ..="cd .."
alias ...="cd ../.."
alias -- -="cd -"

alias 1='pushd -1'
alias 2='pushd -2'
alias 3='pushd -3'
alias 4='pushd -4'
alias 5='pushd -5'
alias 6='pushd -6'
alias 7='pushd -7'
alias 8='pushd -8'
alias 9='pushd -9'

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

alias l='ls -Fh --hyperlink=auto'
alias ll='ls -lAFh --hyperlink=auto'
alias la='ls -AFh --hyperlink=auto'
