set -x PATH $HOME/.local/bin $HOME/bin /usr/local/bin $PATH

function tmux
	set TMUX "command tmux $argv"
	set SHELL /usr/bin/bash
	script -qO /dev/null -c "eval $TMUX"
end

function starship_transient_prompt_func
  starship module character
end

function noproxy
	set -e ALL_PROXY
	set -e HTTP_PROXY
	set -e HTTPS_PROXY
end

function setproxy
	set IP "127.0.0.1"
	set PORT "2080"
	set PROT "socks5"

	for arg in $argv
		switch $arg
			case "-socks" "-socks5"     # set socks proxy (local DNS)
				set PROT "socks5"
			case "-socks5h"               # set socks proxy (remote DNS)
				set PROT "socks5h"
			case "-http" "-https"                  # set HTTP proxy
				set PROT "http"
			case '*'
				if not string match -r -- '-.*' $arg > /dev/null
					set PORT $arg
				end
		end
	end

	set PROXY "$PROT://$IP:$PORT"

	set -x HTTP_PROXY $PROXY
	set -x HTTPS_PROXY $PROXY
	set -x ALL_PROXY $PROXY
	set -x NO_PROXY "localhost,127.0.0.1"
	echo "Proxy set to: $PROXY"
end

if status is-interactive
	# Commands to run in interactive sessions can go here
	set fish_greeting
	setproxy > /dev/null
	starship init fish | source
	eval "$(zoxide init fish)"
	enable_transience
end
