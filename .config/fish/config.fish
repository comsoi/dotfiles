set -x PATH $HOME/.local/bin $HOME/bin $PATH


if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
    proxy_on >/dev/null
end
