## 10-functions.zsh

fpath=(${ZDOTDIR}/functions $fpath)
autoload -Uz get_color_brightness env_append env_insert fuck 
autoload -Uz cpcopy cpaste

# Store commands in history only if successful
autoload -Uz __fd18et_prevent_write __fd18et_save_last_successed
add-zsh-hook zshaddhistory __fd18et_prevent_write
add-zsh-hook precmd __fd18et_save_last_successed
add-zsh-hook zshexit __fd18et_save_last_successed

if [[ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash" ]] {
	source "${XDG_CONFIG_HOME:-${HOME}/.config}/bash/30-functions.bash"
}

