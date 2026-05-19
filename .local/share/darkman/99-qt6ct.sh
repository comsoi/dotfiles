qt_config="${XDG_CONFIG_HOME:-$HOME/.config}/qt6ct/qt6ct.conf"
kde_globals="${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals"

for dir in "${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes" "/usr/share/color-schemes"; do
	[[ -f "$dir/$QT6CT_COLOR.colors" ]] && { color_path="$dir/$QT6CT_COLOR.colors"; break; }
done

can_kde=false
if ! systemctl --user --quiet is-active plasma-workspace.target; then
	can_kde=true
	echo "KDE Globals update enabled."
fi

_qt6ct() { [[ -f "$qt_config" ]] && sed -i "s|^$1=.*|$1=$2|" "$qt_config"; }
_kde()   { "$can_kde" && kwriteconfig6 --file "$kde_globals" --group "$1" --key "$2" "$3"; }

if [[ -n "${color_path:-}" ]]; then
	_qt6ct color_scheme_path "$color_path"
	_kde General ColorScheme "$QT6CT_COLOR"
	echo "QT color scheme set to '$QT6CT_COLOR' from '$color_path'."
fi

_qt6ct icon_theme "$QT6CT_ICON"
_kde Icons Theme "$QT6CT_ICON"
echo "QT icon theme set to '$QT6CT_ICON'."

_qt6ct style "$QT6CT_WIDGET"
_kde KDE widgetStyle "$QT6CT_WIDGET"
echo "QT widget style set to '$QT6CT_WIDGET'."

kvantummanager --set "$QT6CT_KVANTUM"
