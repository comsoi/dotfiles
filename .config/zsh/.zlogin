if [[ ${OS} == "WSL1" ]]; then
	is_sshd_running=`ps aux | grep sshd | grep -v grep`
	if [ -z "$is_sshd_running" ]; then
		sudo service ssh start > /dev/null
	fi
fi
