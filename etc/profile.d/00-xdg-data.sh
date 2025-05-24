export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export GOPATH="$XDG_DATA_HOME"/go
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine
export XCURSOR_PATH="${XCURSOR_PATH:+${XCURSOR_PATH}:}$XDG_DATA_HOME/icons:$HOME/.icons:/usr/share/icons"
