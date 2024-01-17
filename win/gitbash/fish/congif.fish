function tmux
    # execute tmux with script
    set TMUX "command tmux $argv"
    set SHELL /usr/bin/bash
    script -qO /dev/null -c "eval $TMUX"
end
