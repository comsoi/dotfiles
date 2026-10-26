#!/bin/bash

set -euo pipefail # 启用严格模式，更好的错误处理

# 获取脚本相关路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "${SCRIPT_DIR}")"

# 配置文件列表
file_names=(
	".bash_profile"
	".bashrc"
	".zshenv"
	".config/bash"
	".config/fish"
	".config/zsh"
	# cli
	".config/vim"
	".config/nvim"
	".config/tmux"
	".config/bat"
	".config/yazi"
	".config/completions"
	# Terminals
	".config/foot"
	".config/kitty"
	".config/wezterm"
	".config/zellij"
	# Desktops
	".config/fontconfig"
	".config/user-dirs.dirs"
	# ".config/gtk-3.0"
	# ".config/gtk-4.0"
	# KDE Plasma
	".config/plasma-workspace/env"
	# WM
	".config/hypr"
	".config/rofi"
	".config/waybar"
	".config/waypaper"
	".config/wleave"
	".config/nwg-dock-hyprland"
	".config/gnome-mimelist.lists"
)

create_symlink() {
	local source_path="$1"
	local target_path="$2"

	if [[ ! -e "${source_path}" ]]; then
		echo "Error: Source file '${source_path}' does not exist"
		return 1
	fi

	echo "Creating link: ln -s ${source_path} ${target_path}"
	read -p "Are you sure you want to create this symbolic link? (Y/n) " -n 1 -r
	echo

	if [[ ! ($REPLY == "" || $REPLY =~ ^[Yy]$) ]]; then
		echo "Operation cancelled by user"
		return 0
	fi

	if [[ -e "${target_path}" ]]; then
		echo "Warning: Target '${target_path}' already exists"
		read -p "Do you want to overwrite it? (y/N) " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]]; then
			echo "Skipping..."
			return 0
		fi
		rm -rf "${target_path}"
	fi

	# 创建目标目录（如果不存在）
	mkdir -p "$(dirname "${target_path}")"

	# 计算相对路径
	relative_path=$(realpath --relative-to="$(dirname "${target_path}")" "${source_path}")

	# 创建符号链接
	if ln -s "${relative_path}" "${target_path}"; then
		echo "Symbolic link created successfully"
	else
		echo "Failed to create symbolic link"
		return 1
	fi
}

# 清点 .config/user-dirs.dirs 里声明的目录是否真实存在。
# 为什么需要：登录时跑 xdg-user-dirs-update，任何列在里面却不存在的目录都会被
# 重置成 $HOME 并重写整个文件（自定义的 SCREENSHOTS/PROJECTS 键会一起丢）。
check_user_dirs() {
	local dirs_file="${PARENT_DIR}/.config/user-dirs.dirs"

	if [[ ! -f "${dirs_file}" ]]; then
		echo "Warning: ${dirs_file} not found, skipping user-dirs check"
		return 0
	fi

	echo "Checking XDG user directories declared in .config/user-dirs.dirs..."

	local missing=0 line var value
	while IFS= read -r line; do
		[[ "${line}" =~ ^XDG_[A-Z_]+_DIR= ]] || continue
		var="${line%%=*}"
		value="${line#*=}"
		# 去掉两侧双引号
		value="${value%\"}"
		value="${value#\"}"
		# 只做 $HOME / ${HOME} 展开，其余原样（与 xdg-user-dirs 的写法约定一致）
		value="${value//\$\{HOME\}/${HOME}}"
		value="${value//\$HOME/${HOME}}"

		if [[ -d "${value}" ]]; then
			echo "  [ok]      ${var}=${value}"
		else
			echo "  [missing] ${var}=${value}"
			((missing++))
		fi
	done < <(grep -v '^[[:space:]]*#' "${dirs_file}")

	if ((missing > 0)); then
		echo
		echo "Error: ${missing} XDG user dir(s) missing."
		echo "先 mkdir -p 建好上面标 [missing] 的目录，否则下次登录时"
		echo "xdg-user-dirs-update 会把它们重置成 \$HOME 并改写 user-dirs.dirs。"
		return 1
	fi
}

# 主程序
main() {
	local errors=0

	for file_name in "${file_names[@]}"; do
		echo "Processing ${file_name}..."
		if ! create_symlink "${PARENT_DIR}/${file_name}" "${HOME}/${file_name}"; then
			((errors++))
		fi
		echo
	done

	if ! check_user_dirs; then
		((errors++))
	fi
	echo

	if ((errors > 0)); then
		echo "Completed with ${errors} error(s)"
		exit 1
	fi

	echo "All symbolic links created successfully"
}

main "$@"
