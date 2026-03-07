# ~/.bashrc
[[ $- != *i* ]] && return

BASH_COMPLETION_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash:${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion:${BASH_COMPLETION_USER_DIR}"

if [[ $(tty) == /dev/pts/* ]]; then
	export LANG=zh_CN.UTF-8
	export LANGUAGE=zh_CN:en_US:en
fi

for file in ~/.config/bash/*.bash; do
	[[ -f "$file" ]] && . "$file"
done

unset file
