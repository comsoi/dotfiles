# Detect current shell
if [ -n "$BASH_VERSION" ]; then
    CURRENT_SHELL="bash"
elif [ -n "$ZSH_VERSION" ]; then
    CURRENT_SHELL="zsh"
else
    echo "Unsupported shell."
    return 1  # or 'exit 1' if you want to exit in error cases
fi

# Set TITLEPREFIX
if [ -f /etc/profile.d/git-sdk.sh ]; then
    TITLEPREFIX=SDK-${MSYSTEM#MINGW}
else
    TITLEPREFIX=$MSYSTEM
fi

# Function to load git prompt and completion for Bash
load_git_for_bash() {
    GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
    COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
    COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
    COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"

    if [ -f "$COMPLETION_PATH/git-completion.bash" ]; then
        . "$COMPLETION_PATH/git-completion.bash"
    fi
    if [ -f "$COMPLETION_PATH/git-prompt.sh" ]; then
        . "$COMPLETION_PATH/git-prompt.sh"
        PS1="$PS1"'\[\033[36m\]'  # cyan color
        PS1="$PS1"'`__git_ps1`'   # git branch info
    fi
}

# Function to load git prompt for Zsh
load_git_for_zsh() {
    if [ -f "$HOME/.config/git/git-prompt.sh" ]; then
        . "$HOME/.config/git/git-prompt.sh"
        PS1="$PS1"'$(__git_ps1 " (%s)")' # git branch info
    fi
}

# Common PS1 configuration
set_ps1() {
    PS1='\[\033]0;$TITLEPREFIX:$PWD\007\]' # set window title
    PS1="$PS1"'\n'                         # new line
    PS1="$PS1"'\[\033[32m\]'               # green
    PS1="$PS1"'\u@\h '                     # user@host<space>
    PS1="$PS1"'\[\033[35m\]'               # purple
    PS1="$PS1"'$MSYSTEM '                  # MSYSTEM
    PS1="$PS1"'\[\033[33m\]'               # brownish yellow
    PS1="$PS1"'\w'                         # working directory
}

# Load configurations based on the current shell
case "$CURRENT_SHELL" in
    bash)
        set_ps1
        load_git_for_bash
        PS1="$PS1"'\[\033[0m\]'            # reset color
        PS1="$PS1"'\n$ '                   # new line and prompt
        MSYS2_PS1="$PS1"                   # for MSYS2
        ;;
    zsh)
        set_ps1
        load_git_for_zsh
        PS1="$PS1"'\[\033[0m\]'            # reset color
        PS1="$PS1"'\n%#'                   # new line and prompt (zsh style)
        ;;
    *)
        echo "Unsupported shell: $CURRENT_SHELL"
        ;;
esac

# Make sure this script is being sourced, not executed
if [ "$0" = "$BASH_SOURCE" ] || [ "$0" = "$ZSH_SOURCE" ]; then
    echo "This script should be sourced, not executed."
    return 1
fi
