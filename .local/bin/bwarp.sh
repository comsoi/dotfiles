bwBindPath="$HOME/Downloads/"
IFS=':' read -ra _paths <<<"$bwBindPath"
bwBindPath=""
for path in "${_paths[@]}"; do
	bwBindPath+="--dev-bind $path $path "
done

bwrap --unshare-all --share-net --die-with-parent --ro-bind / / \
	--tmpfs /sys --tmpfs /home --tmpfs /tmp --tmpfs /run --proc /proc --dev /dev \
	--ro-bind ~/.config/bash ~/.config/bash \
	--ro-bind ~/.config/dotfiles ~/.config/dotfiles \
	--ro-bind ~/.config/zsh ~/.config/zsh \
	--ro-bind ~/.zshenv ~/.zshenv \
	--ro-bind ~/workspaces/swap ~/workspaces/swap \
	--bind ~/.cache/fontconfig ~/.cache/fontconfig \
	$bwBindPath \
	--ro-bind /run/user/$UID/${WAYLAND_DISPLAY:-wayland-0} /run/user/$UID/${WAYLAND_DISPLAY:-wayland-0} \
	--ro-bind /run/user/$UID/pipewire-0 /run/user/$UID/pipewire-0 \
	--ro-bind /run/user/$UID/pipewire-0-manager /run/user/$UID/pipewire-0-manager \
	--ro-bind /run/user/$UID/pulse /run/user/$UID/pulse \
	--ro-bind /tmp/.X11-unix /tmp/.X11-unix --ro-bind /run/user/$UID/bus /run/user/$UID/bus \
	--chdir ~ /bin/bash
