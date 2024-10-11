# If not running interactively, don't do anything
[[ $- != *i* ]] && return


if [[ -r "${ZDOTDIR}/00-init" ]]; then
	source ${ZDOTDIR}/00-init
fi
if [[ -r "${ZDOTDIR}/00-init-omz" ]]; then
    source ${ZDOTDIR}/00-init-omz
fi
if [[ -r "${ZDOTDIR}/20-keybinding" ]]; then
	source ${ZDOTDIR}/20-keybinding
fi
if [[ -r "${ZDOTDIR}/20-completion" ]]; then
	source ${ZDOTDIR}/20-completion
fi
if [[ -r "${ZDOTDIR}/30-functions" ]]; then
	source ${ZDOTDIR}/30-functions
fi
if [[ -r "${ZDOTDIR}/40-aliases" ]]; then
	source ${ZDOTDIR}/40-aliases
fi
if [[ -r "${ZDOTDIR}/50-custom" ]]; then
    source ${ZDOTDIR}/50-custom
fi

# Initialize tools

if [[ $(command -v fzf) ]]; then
    source <(fzf --zsh)
fi

if [[ $(command -v zoxide) ]]; then
	eval "$(zoxide init zsh --cmd j)"
fi

if [[ $(command -v thefuck) ]]; then
	fuck () { # eval $(thefuck --alias)
		TF_PYTHONIOENCODING=$PYTHONIOENCODING;
		export TF_SHELL=zsh;
		export TF_ALIAS=fuck;
		TF_SHELL_ALIASES=$(alias);
		export TF_SHELL_ALIASES;
		TF_HISTORY="$(fc -ln -10)";
		export TF_HISTORY;
		export PYTHONIOENCODING=utf-8;
		TF_CMD=$(
			thefuck THEFUCK_ARGUMENT_PLACEHOLDER $@
		) && eval $TF_CMD;
		unset TF_HISTORY;
		export PYTHONIOENCODING=$TF_PYTHONIOENCODING;
		test -n "$TF_CMD" && print -s $TF_CMD
	}
fi
