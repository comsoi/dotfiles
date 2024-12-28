## 30-functions.zsh
autoload -Uz add-zsh-hook

if [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash" ]] {
	source "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash"
}

autoload -Uz get_color_brightness append_env cbprint cbcopy fuck
autoload -Uz __fd18et_setup_history_hooks

__fd18et_setup_history_hooks

# plugins
source ${ZDOTDIR}/plugins/completion.plugin.zsh
if [[ ! $USE_OMZ ]] {
	source ${ZDOTDIR}/plugins/sudo.plugin.zsh
	source ${ZDOTDIR}/plugins/zsh-tab-title.plugin.zsh
}
