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
	# Desktops
	".config/fontconfig"
	".config/gtk-2.0"
	".config/gtk-3.0"
	".config/gtk-4.0"
	# KDE Plasma
	".config/plasma-workspace/env"
	# WM
	".config/hypr"
	".config/waybar"
	".config/waypaper"
	".config/wlogout"
	".config/nwg-dock-hyprland"

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

	if ((errors > 0)); then
		echo "Completed with ${errors} error(s)"
		exit 1
	fi

	echo "All symbolic links created successfully"
}

main "$@"
