setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
unsetopt AUTO_REMOVE_SLASH
unsetopt HIST_EXPIRE_DUPS_FIRST
unsetopt EXTENDED_HISTORY
HISTFILE=$ZDOTDIR/.history

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh
# Plugins
if [[ -r /usr/share/zsh/plugins ]]; then
	source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
	source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -r "${ZDOTDIR}/plugins/custom" ]]; then
	source ${ZDOTDIR}/plugins/custom/zsh-autosuggestions/zsh-autosuggestions.zsh
	source ${ZDOTDIR}/plugins/custom/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
	source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
# Theme
if [[ -r "/usr/share/zsh-theme-powerlevel10k" ]]; then
	POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  POWERLEVEL9K_TERM_SHELL_INTEGRATION=true
	source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
elif [[ -r "${ZDOTDIR}/themes/powerlevel10k" ]]; then
	POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
	source ${ZDOTDIR}/themes/powerlevel10k/powerlevel10k.zsh-theme
elif [[ -r "${HOME}/.powerlevel10k" ]]; then
	POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
	source ${HOME}/.powerlevel10k/powerlevel10k.zsh-theme
fi
