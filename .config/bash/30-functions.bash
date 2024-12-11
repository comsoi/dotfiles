#!/bin/bash

#
# ~/.bash_functions
#

# Some example functions:
#
# a) function settitle
# settitle ()
# {
#   echo -ne "\e]2;$@\a\e]1;$@\a";
# }
#
# b) function cd_func
# This function defines a 'cd' replacement function capable of keeping,
# displaying and accessing history of visited directories, up to 10 entries.
# To use it, uncomment it, source this file and try 'cd --'.
# acd_func 1.0.5, 10-nov-2004
# Petar Marinov, http:/geocities.com/h2428, this is public domain
mkcd() {
  mkdir -p -- "$1" &&
    cd -- "$1"
}

tmux() {
  if ! command -v tmux &>/dev/null; then
    echo "tmux is not installed. Please install tmux using your package manager."
    return 1
  fi

  # If already inside a tmux session, open a new window
  if [[ -n $TMUX ]]; then
    if [[ $# -eq 0 ]]; then
      command tmux new-window
      return
    else
      command tmux "$@"
    fi
  fi

  # If not inside a tmux session, attach to an existing session or start a new one
  if [[ $# -eq 0 ]]; then
    command tmux attach-session || command tmux new-session
  else
    command tmux "$@"
  fi
}

cd_func() {
  local x2 the_new_dir adir index
  local -i cnt

  if [[ $1 == "--" ]]; then
    dirs -v
    return 0
  fi

  the_new_dir=$1
  [[ -z $1 ]] && the_new_dir=$HOME

  if [[ ${the_new_dir:0:1} == '-' ]]; then
    #
    # Extract dir N from dirs
    index=${the_new_dir:1}
    [[ -z $index ]] && index=1
    adir=$(dirs +$index)
    [[ -z $adir ]] && return 1
    the_new_dir=$adir
  fi

  #
  # '~' has to be substituted by ${HOME}
  [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

  #
  # Now change to the new dir and add to the top of the stack
  pushd "${the_new_dir}" >/dev/null
  [[ $? -ne 0 ]] && return 1
  the_new_dir=$(pwd)

  #
  # Trim down everything beyond 11th entry
  popd -n +11 2>/dev/null 1>/dev/null

  #
  # Remove any other occurence of this dir, skipping the top of the stack
  for ((cnt = 1; cnt <= 10; cnt++)); do
    x2=$(dirs +${cnt} 2>/dev/null)
    [[ $? -ne 0 ]] && return 0
    [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
    if [[ "${x2}" == "${the_new_dir}" ]]; then
      popd -n +$cnt 2>/dev/null 1>/dev/null
      cnt=cnt-1
    fi
  done

  return 0
}

function eza_gs() {
  eza -al --group-directories-first --git --git-ignore --no-user --no-filesize --no-time --no-permissions --tree --color=always | awk '$1 !~ /--/ { print }'
}

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

get_model() {
  case $OS in
  Linux)
    if [[ -d /system/app/ && -d /system/priv-app ]]; then
      model="$(getprop ro.product.brand) $(getprop ro.product.model)"

    elif [[ -f /sys/devices/virtual/dmi/id/product_name ||
      -f /sys/devices/virtual/dmi/id/product_version ]]; then
      model=$(</sys/devices/virtual/dmi/id/product_name)
      model+=" $(</sys/devices/virtual/dmi/id/product_version)"

    elif [[ -f /sys/firmware/devicetree/base/model ]]; then
      model=$(</sys/firmware/devicetree/base/model)

    elif [[ -f /tmp/sysinfo/model ]]; then
      model=$(</tmp/sysinfo/model)
    fi
    ;;

  "Mac OS X" | "macOS" | "Mac")
    if [[ $(kextstat | grep -F -e "FakeSMC" -e "VirtualSMC") != "" ]]; then
      model="Hackintosh (SMBIOS: $(sysctl -n hw.model))"
    else
      model=$(sysctl -n hw.model)
    fi
    ;;

  Windows)
    model=$(wmic computersystem get manufacturer,model)
    model=${model/Manufacturer/}
    model=${model/Model/}
    ;;

  esac

  # Remove dummy OEM info.
  model=${model//To be filled by O.E.M./}
  model=${model//To Be Filled*/}
  model=${model//OEM*/}
  model=${model//Not Applicable/}
  model=${model//System Product Name/}
  model=${model//System Version/}
  model=${model//Undefined/}
  model=${model//Default string/}
  model=${model//Not Specified/}
  model=${model//Type1ProductConfigId/}
  model=${model//INVALID/}
  model=${model//All Series/}
  model=${model//�/}

  case $model in
  "Standard PC"*) model="KVM/QEMU (${model})" ;;
  OpenBSD*) model="vmm ($model)" ;;
  esac
}

function noproxy() {
  unset ALL_PROXY
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset NO_PROXY
  echo "Proxy settings removed."
}

function setproxy() {
  # local IP=$(grep "nameserver" /etc/resolv.conf | cut -f 2 -d ' ')
  local IP="127.0.0.1"
  local PORT="7897"
  if [[ ${OS} == "WSL2" ]]; then
    IP=172.22.48.1
  else
    get_model
    if [[ ${model} == *"VMware"* ]]; then
      local ip_address=$(ip a | grep 'scope global dynamic' | awk '{print $2}')
      IP=$(echo "$ip_address" | sed 's/\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)\.[0-9]\{1,3\}/\1.1/; s/\/[0-9]\{1,2\}//')
      PORT="7891"
    fi
  fi
  local PROT="http"

  for arg in "$@"; do
    case "$arg" in
    "-socks" | "-socks5") # set socks proxy (local DNS)
      PROT="socks5"
      ;;
    "-socks5h") # set socks proxy (remote DNS)
      PROT="socks5h"
      ;;
    "-http" | "-https") # set HTTP proxy
      PROT="http"
      ;;
    *)
      if [[ "$arg" != -* ]]; then
        PORT="$arg"
      fi
      ;;
    esac
  done

  local PROXY="$PROT://$IP:$PORT"

  export HTTP_PROXY="$PROXY"
  export HTTPS_PROXY="$PROXY"
  export ALL_PROXY="$PROXY"
  export NO_PROXY="localhost,127.0.0.1"
  echo "Proxy set to: $PROXY"
}
