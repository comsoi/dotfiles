case $- in *i*) echo interactive; esac # that should work in any Bourne/POSIX shell
case :$BASHOPTS: in (*:login_shell:*) echo login; esac