if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(history)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=1

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

plugins=(
	conda-zsh-completion
	command-not-found
	extract
	deno
	docker
	git
	github
	gitignore
	history-substring-search
	node
	npm
	nvm
	volta
	vscode
	sudo
	web-search
	# z
	zsh-autosuggestions
	zsh-syntax-highlighting
	ohmyzsh-full-autoupdate
)

source $ZSH/oh-my-zsh.sh

# User configuration

PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/d/Scoop/apps/tdm-gcc/current/bin:$PATH"
export LANG=zh_CN.UTF-8
#export LC_ALL=zh_CN.UTF-8
#export LANGUAGE=zh_CN.UTF-8
export PYTHONIOENCODING=UTF-8
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"

# Compilation flags
export ARCHFLAGS="-arch x86_64"

if [ -f ~/.aliases_func ]; then
    . ~/.aliases_func
fi
# initial cursor shape
echo -ne '\e[5 q'

setproxy > /dev/null

eval "$(zoxide init zsh)"

[[ "$TERM_PROGRAM" == "vscode" ]] && . "/d/Scoop/apps/vscode/current/resources/app/out/vs/workbench/contrib/terminal/browser/media/shellIntegration-rc.zsh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if [ -f '/d/programs/conda/Scripts/conda.exe' ]; then
# 	eval "$('/d/programs/conda/Scripts/conda.exe' 'shell.zsh' 'hook' | sed -e 's/"$CONDA_EXE" $_CE_M $_CE_CONDA "$@"/"$CONDA_EXE" $_CE_M $_CE_CONDA "$@" | tr -d \x27\\r\x27/g')"
# fi
# # <<< conda initialize <<<
