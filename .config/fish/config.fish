# 设置 PATH
set -x PATH $HOME/.local/bin $HOME/bin /usr/local/bin $PATH

function noproxy
    set -e all_proxy
    set -e ALL_PROXY
    set -e http_proxy
    set -e HTTP_PROXY
    set -e https_proxy
    set -e HTTPS_PROXY
end

function setproxy
    # set host_ip (grep "nameserver" /etc/resolv.conf | cut -f 2 -d ' ')
    set host_ip "127.0.0.1"
    set host_port "2080"

    set -x all_proxy "http://$host_ip:$host_port"
    set -x ALL_PROXY "http://$host_ip:$host_port"
    set -x http_proxy "http://$host_ip:$host_port"
    set -x HTTP_PROXY "http://$host_ip:$host_port"
    set -x https_proxy "http://$host_ip:$host_port"
    set -x HTTPS_PROXY "http://$host_ip:$host_port"

    echo "Proxy set to: $host_ip:$host_port"
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting
    setproxy > /dev/null
end
