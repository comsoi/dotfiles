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
	kimi-cli
	autoswitch_virtualenv
)

is_plugin() {
	local base_dir=$1
	local name=$2
	builtin test -f $base_dir/$name/$name.plugin.zsh \
		|| builtin test -f $base_dir/$name/_$name
}

for plugin ($PLUGINS); do
	local found=0
	for base_dir ($PLUGIN_PATHS); do
		if is_plugin "$base_dir" "$plugin"; then
			fpath=("$base_dir/$plugin" $fpath)
			[[ -f "$base_dir/$plugin/$plugin.plugin.zsh" ]] \
				&& source "$base_dir/$plugin/$plugin.plugin.zsh"
			found=1
			break
		fi
	done
	(( found )) || echo "[zsh] plugin '$plugin' not found"
done

source ${ZDOTDIR}/plugins/completion.plugin.zsh

[[ $USE_OMZ ]] && return

source ${ZDOTDIR}/plugins/sudo.plugin.zsh
source ${ZDOTDIR}/plugins/zsh-tab-title.plugin.zsh
