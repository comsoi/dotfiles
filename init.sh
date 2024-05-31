#!/usr/bin/env bash

# Array to log failed commands
fail_cmds=()

# Function to execute a command and log it if it fails
execute_with_log() {
    cmd="$*"
    if ! eval "$cmd"; then
        echo "Command '$cmd' failed."
        fail_cmds+=("$cmd")
    fi
}

has_sudo() {
    local prompt
    prompt=$(sudo -nv 2>&1)
    if [ $? -eq 0 ]; then
        return 0
        elif echo $prompt | grep -q '^sudo:'; then
        return 0
    else
        echo "No sudo."
    fi
}

# At the end, log all failed commands
echo_fail() {
    if [ ${#fail_cmds[@]} -gt 0 ]; then
        echo "==================Failed Commands=================="
        for cmd in "${fail_cmds[@]}"; do
            echo "$cmd"
        done
    else
        echo "All commands executed successfully."
    fi
}

apt_way() {
    echo "==================Updating apt=================="
    execute_with_log "$SUDO apt update && apt upgrade -y"

    echo "==================Installing build-essential=================="
    execute_with_log "$SUDO apt install -y build-essential"

    echo "==================Installing zsh=================="
    execute_with_log "$SUDO apt install -y git zsh zsh-syntax-highlighting zsh-autosuggestions"

    echo "==================Installing zsh plugins=================="
    execute_with_log "mkdir -p ~/.config/zsh"
    execute_with_log "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/zsh/.powerlevel10k"

    echo "Installing zoxide"
    execute_with_log "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"

    echo "Installing thefuck"
    execute_with_log "$SUDO apt install -y thefuck"

    echo "==================Installing tools=================="

    echo "Installing bat"
    execute_with_log "$SUDO apt install -y bat"
    execute_with_log "mkdir -p ~/.local/bin"
    execute_with_log "ln -s /usr/bin/batcat ~/.local/bin/bat"

    echo "Installing eza"
    execute_with_log "$SUDO apt install -y gpg"
    execute_with_log "$SUDO mkdir -p /etc/apt/keyrings"
    execute_with_log "wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg"
    execute_with_log "echo 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' | sudo tee /etc/apt/sources.list.d/gierens.list"
    execute_with_log "$SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list"
    execute_with_log "$SUDO apt update"
    execute_with_log "$SUDO apt install -y eza"

    echo "Installing lsd"
    execute_with_log "$SUDO apt install -y lsd"
}

pacman_way() {
    execute_with_log pacman -S base-devel python-setuptools zsh zsh-syntax-highlighting zsh-autosuggestions thefuck bat eza lsd ttf-firacode-nerd noto-fonts-cjk
}

detect_attribution() {
    local os='head -1 /etc/os-release'
    if [[ "${os}" == *"Arch"* ]]; then
        pacman_way
    fi
}

install_start() {
    SUDO=''
    if (( $EUID != 0 )); then
        SUDO='sudo'
        if [[ $(command -v sudo) ]]; then
            echo "sudo is installed"
            if has_sudo; then
                echo "sudo is set"
            else
                echo "user is not in sudoers file"
            fi
        else
            echo "sudo is not installed"
            echo "try to install sudo"
            exit 1
        fi
    else
        echo "user is root or script is running with sudo"
        echo "if you want to install for the current user, please run the script without sudo"
        echo "Want to continue? (y/n)"
        read -r CONTINUE
        if [[ $CONTINUE != "y" ]]; then
            exit 1
        fi
        echo "Want to create a new user with sudo? (y/n)"
        read -r NEW_USER
        if [[ $NEW_USER == "y" ]]; then
            echo "Enter username"
            read -r USERNAME
            execute_with_log "$SUDO adduser $USERNAME"
            execute_with_log "$SUDO usermod -aG sudo $USERNAME"
        fi
    fi

    echo "==================Checking proxy=================="
    if env | grep -iq proxy; then
        echo "Proxy is set."
    else
        echo "Proxy is not set."
        echo "DO YOU WANT TO SET PROXY? (y/n)"
        read -r PROXY
        if [[ $PROXY == "y" ]]; then
            echo "Enter proxy address"
            read -r PROXY_ADDRESS
            echo "Enter proxy port"
            read -r PROXY_PORT
            export http_proxy="http://$PROXY_ADDRESS:$PROXY_PORT"
            export https_proxy="http://$PROXY_ADDRESS:$PROXY_PORT"
            export no_proxy="localhost"
        fi
    fi
    detect_attribution && echo_fail
}

{
    install_start || exit 1
}
