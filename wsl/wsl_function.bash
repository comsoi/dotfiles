stnix() {
    sudo service binfmt-support start
}

stssh() {
    sudo service ssh start
}


isWSL1() {
	if grep -q Microsoft /proc/version; then
		return 0
	else
		return 1
	fi
}