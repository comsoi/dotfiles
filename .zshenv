export GNUTERM=sixel
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH

# You may need to manually set your language environment
if tty -s; then
    export LANG="en_US.UTF-8"
else
    export LANG="zh_CN.UTF-8"
fi
#export LC_ALL=zh_CN.UTF-8
#export LANGUAGE=zh_CN.UTF-8
export PYTHONIOENCODING=UTF-8
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='lvim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"
