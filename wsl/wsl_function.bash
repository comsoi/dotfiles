stnix() {
    sudo service binfmt-support start
}

stssh() {
    sudo service ssh start
}

# https://github.com/microsoft/WSL/issues/423
isWSL1() {
	if grep -q Microsoft /proc/version; then # $(systemd-detect-virt --container)
		return 0
	else
		return 1
	fi
}