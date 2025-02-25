## 30-functions.zsh

autoload -Uz get_color_brightness env_append env_insert cbprint cbcopy fuck
autoload -Uz __fd18et_setup_history_hooks

if [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash" ]] {
	source "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash"
}
__fd18et_setup_history_hooks

# plugins
source ${ZDOTDIR}/plugins/completion.plugin.zsh
if [[ ! $USE_OMZ ]] {
	source ${ZDOTDIR}/plugins/sudo.plugin.zsh
	source ${ZDOTDIR}/plugins/zsh-tab-title.plugin.zsh
}
