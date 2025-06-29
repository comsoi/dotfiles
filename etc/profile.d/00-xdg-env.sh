export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod

export JUPYTER_PLATFORM_DIRS="1"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export GOPATH="$XDG_DATA_HOME"/go
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine
export XCURSOR_PATH="${XCURSOR_PATH:+${XCURSOR_PATH}:}$XDG_DATA_HOME/icons:$HOME/.icons:/usr/share/icons"
