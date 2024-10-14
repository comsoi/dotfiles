#!/bin/bash

#
# ~/.bashrc
#

[[ -f ${HOME}/.init_profile ]] && . ${HOME}/.init_profile

# [[ $- != *i* ]] && return  # If not running interactively, don't do anything
case $- in
	*i*) ;;
	  *) return;;
esac

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color|*-256color|*kitty*|*alacritty*|wezterm) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

if [ "$color_prompt" = yes ]; then
	PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
	PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;\u@\h: \w\a\]$PS1"
	;;
	*)
	;;
esac

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Functions
if [ -f "${HOME}/.bash_functions" ]; then
	. "${HOME}/.bash_functions"
fi

# Alias definitions.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
	. "${HOME}/.bash_aliases"
fi

# User configuration
if [[ -r "${HOME}/.bash_custom" ]]; then
    source ${HOME}/.bash_custom
fi

if [ "$(command -v zoxide)" ]; then
	# echo "command \"zoxide\" exists on system"
	eval "$(zoxide init bash)"
else
	echo "command \"zoxide\" does not exist on system"
fi

if [ "$(command -v thefuck)" ]; then
	eval "$(thefuck --alias)"
else
	echo "command \"thefuck\" does not exist on system"
fi
