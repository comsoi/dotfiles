# If not running interactively, don't do anything
[[ $- != *i* ]] && return

for file in "${ZDOTDIR}/core/"*; do
    if [[ -r "$file" ]]; then
        source "$file"
    fi
done

# Initialize tools

if command -v fzf >/dev/null && fzf --version | cut -d' ' -f1 | awk '{exit ($1 <= "0.48.0")}'; then
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
