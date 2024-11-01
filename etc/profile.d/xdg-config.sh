export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

export JUPYTER_PLATFORM_DIRS="1"
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export GTK_RC_FILES="$XDG_CONFIG_HOME/gtk-1.0/gtkrc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc":"$XDG_CONFIG_HOME/gtk-2.0/gtkrc.mine"
