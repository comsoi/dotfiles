## 00-init.bash

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

declare -A commands_vars=(
	[fzf]=HAS_FZF
	[zoxide]=HAS_ZOXIDE
	[thefuck]=HAS_THEFUCK
	[win32yank.exe]=HAS_WIN32YANK
	[nala]=HAS_NALA
	[lsd]=HAS_LSD
	[eza]=HAS_EZA
	[trash-put]=HAS_TRASH_PUT
	[bat]=HAS_BAT
	[dircolors]=HAS_DIRCOLORS
)

for cmd in "${!commands_vars[@]}"; do
	if command -v "$cmd" >/dev/null; then
		declare "${commands_vars[$cmd]}=1"
	else
		declare "${commands_vars[$cmd]}=0"
	fi
done

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color | *kitty | alacritty | foot | wezterm) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='\u@\h:\w\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt* | alacritty | foot | wezterm)
	PS1="\[\e]0;\u@\h: \w\a\]$PS1"
	;;
*) ;;
esac
