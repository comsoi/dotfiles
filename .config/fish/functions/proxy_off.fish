function proxy_off
	set -e HTTP_PROXY
	set -e HTTPS_PROXY
	set -e ALL_PROXY
	set -e NO_PROXY
end
