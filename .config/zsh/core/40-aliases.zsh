## 40-aliases.zsh

alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"
alias -- -="cd -"

alias c='clear'
alias ff='fastfetch'
alias shutdown='systemctl poweroff'
alias v='$EDITOR'

alias gs="git status"
alias ga="git add -A"
alias gc="git commit -v"
alias gc!="git commit -v --amend --no-edit"
alias gl="git pull"
alias gp="git push"
alias gp!="git push --force"
alias gcl="git clone --depth 1 --single-branch"
alias gf="git fetch --all"
alias gb="git branch"
alias gr="git rebase"
alias gt='cd "$(git rev-parse --show-toplevel)"'
alias lg=lazygit

alias wget='wget --hsts-file="${XDG_CACHE_HOME:-$HOME/.cache}/wget-hsts"'

alias ipa='ip -br a'
alias rmi='rm -I'
alias tree='tree -aC'
alias r='y '
alias p='prime-run'
alias ipy='ipython'
alias code.='code .'
alias dtb='distrobox-enter'
alias tmux-copy='tmux loadb -'
alias tmux-paste='tmux saveb -'

if (( HAS_WIN32YANK )); then
	alias pbcopy='win32yank.exe -i --crlf'
	alias pbpaste='win32yank.exe -o --lf'
fi

# enable aliases in sudo
alias sudo='sudo '
# let sudo inherit the PATH
alias sudop='command sudo env PATH="$PATH"'

alias proxychains='proxychains '
alias proxychains4='proxychains4 '

# 优化 nala 别名
if (( HAS_NALA )); then
	alias apt="nala"
	alias nala="sudo nala"
fi

# 先检测并设置 dircolors，为所有支持的命令设置颜色输出
if (( HAS_DIRCOLORS )); then
	# builtin test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
	alias diff='diff --color=auto'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'
	alias ip='ip --color=auto'
	alias ls='ls --color=auto'
	alias l='ls -CF --color=auto'
	alias ll='ls -alF --color=auto'
	alias la='ls -A --color=auto'
fi

if (( HAS_LSD )); then
	alias ls="lsd --date +%Y%m%d' '%H:%M"
	alias l="lsd -AF"
	alias ll="lsd -alF"
	alias la="lsd -A"
	alias tree="lsd --tree"
fi

if (( HAS_EZA )); then
	alias l="eza -a --icons --group-directories-first"
	alias ll="eza -al --icons --group-directories-first"
	alias tree="eza --tree --icons --group-directories-first"
	alias ld="eza -lD"                                         # lists only directories
	alias lf="eza -lF --color=always | grep -v /"              # lists only files (no directories)
	alias gs=eza_gs
fi

if (( HAS_TRASH_PUT )); then
	alias rm='echo "You should not use rm directly, use trash-put instead." && rm -I'
	alias trm="trash-put"
	alias tls="trash-list"
	alias trs="trash-restore"
fi

if (( HAS_BAT )); then
	# apt need to set up a bat -> batcat symlink: ln -s /usr/bin/batcat ~/.local/bin/bat
	alias cat="bat"
fi

alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'
alias startlp='sudo systemctl start tlp.service'
