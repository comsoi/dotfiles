export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
