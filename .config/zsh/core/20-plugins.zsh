## 20-plugins.zsh

typeset -a PLUGIN_PATHS=(
	"${ZDOTDIR}/plugins/custom"
	"/usr/share/zsh/plugins"
	"/usr/share"
)
typeset -a PLUGINS=(
	zsh-autosuggestions
	zsh-syntax-highlighting
	zsh-vi-mode
	zsh-no-ps2
)
for plugin (${PLUGINS[@]}) {
	for plugin_file (${^PLUGIN_PATHS}/$plugin/$plugin.plugin.zsh(N)) {
		source $plugin_file
		break
	}
}

# custom plugins
source ${ZDOTDIR}/plugins/completion.plugin.zsh
if [[ $USE_OMZ ]] {
	return
}
source ${ZDOTDIR}/plugins/sudo.plugin.zsh
source ${ZDOTDIR}/plugins/zsh-tab-title.plugin.zsh
