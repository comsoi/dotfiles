# ~/.profile

[ -z "$HOME" ] && exit

export EDITOR='nvim'
export LESS="-R"

add_env() {
	local mode="insert"
	local sep=":"

	while [ $# -gt 0 ]; do
		case "$1" in
		-a | --append)
			mode="append"
			shift
			;;
		-i | --insert)
			mode="insert"
			shift
			;;
		-s=* | --sep=*)
			sep="${1#*=}"
			shift
			;;
		-*)
			echo "Unknown option: $1" >&2
			return 1
			;;
		*)
			break
			;;
		esac
	done

	# 确保至少有一个参数（环境变量名）
	if [ $# -lt 1 ]; then
		echo "No environment variable name specified" >&2
		return 1
	fi

	local env_name="$1"
	shift

	# 处理所有值
	eval val="\$$env_name"

	for value in "$@"; do
		# 检查值是否已存在
		case "$sep$val$sep" in
		*"$sep$value$sep"*) continue ;;
		esac

		# 添加值
		if [ -z "$val" ]; then
			val="$value"
		elif [ "$mode" = "append" ]; then
			val="$val$sep$value"
		else
			val="$value$sep$val"
		fi
	done

	# 设置环境变量
	eval "$env_name=$val"
}

{
	unameOut=$(uname -a)
	case "${unameOut}" in
	*Microsoft*) OS="WSL1" ;;
	*microsoft*) OS="WSL2" ;;
	Linux*) OS="Linux" ;;
	Darwin*) OS="Mac" ;;
	CYGWIN*) OS="Cygwin" ;;
	MINGW*) OS="Windows" ;;
	*Msys) OS="Windows" ;;
	*) OS="UNKNOWN:${unameOut}" ;;
	esac

	if [ "${OS}" = "Mac" ] && sysctl -n machdep.cpu.brand_string | grep -q 'Apple M'; then
		OS="MacArm"
	fi
	unset unameOut
	export OS
}

add_env PATH "$HOME/.local/bin"
export PATH
