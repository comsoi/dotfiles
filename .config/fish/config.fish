set -x PATH $HOME/.local/bin $HOME/bin $PATH

# set fish_complete_path $XDG_CONFIG_HOME/completions/fish $fish_complete_path

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
    proxy_on >/dev/null
end
