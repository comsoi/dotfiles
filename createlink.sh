#!/bin/bash

# Get the absolute path of the current directory
current_dir=$(pwd)

file_names=(
    ".bash_aliases"
    ".bash_functions"
    ".bash_profile"
    ".bashrc"
    ".clang-format"
    ".config/zsh/"
    ".config/completions/"
    ".inputrc"
    ".init_profile"
    ".vimrc"
    ".zshenv"
)
for file_name in "${file_names[@]}"; do
    # Check if the file exists in the current directory
    if [[ -e "${current_dir}/${file_name}" ]]; then
        # Ask the user for confirmation
        # If the file is a directory, remove the directory name from the target path
        if [[ -d "${current_dir}/${file_name}" ]]; then
            target_path="${HOME}/$(dirname ${file_name})"
        else
            target_path="${HOME}/${file_name}"
        fi
        echo "ln -s ${current_dir}/${file_name} ${target_path}"
        read -p "Are you sure you want to create a symbolic link for ${file_name}? (y/n) " -n 1 -r

        echo    # move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then

            # Create a symbolic link
            ln -s "${current_dir}/${file_name}" "${target_path}"
            if [[ $? -eq 0 ]]; then
                echo "Symbolic link created successfully"
            else
                echo "Failed to create symbolic link"
            fi
        else
            echo "Operation cancelled by user"
        fi
        echo
    else
        echo "${file_name} does not exist in the current directory"
    fi
done