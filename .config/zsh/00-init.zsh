setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
unsetopt AUTO_REMOVE_SLASH
unsetopt HIST_EXPIRE_DUPS_FIRST
unsetopt EXTENDED_HISTORY

# p10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
[[ ! -f ${ZDOTDIR}/.p10k.zsh ]] || source ${ZDOTDIR}/.p10k.zsh

HISTFILE=$ZDOTDIR/.history
# Plugins
if [[ -r /usr/share/zsh/plugins ]]; then
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
else
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
# NOTICE .powerlevel10k/ !!!
if [[ -r "${ZDOTDIR}/.powerlevel10k" ]]; then
    POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    source ${ZDOTDIR}/.powerlevel10k/powerlevel10k.zsh-theme
    elif [[ -r /usr/share/zsh-theme-powerlevel10k ]]; then
    POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
    elif [[ -r "${HOME}/.powerlevel10k" ]]; then
    POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
    source ${HOME}/.powerlevel10k/powerlevel10k.zsh-theme
fi