#!/bin/bash
pkill wlogout || exec "$(dirname "$0")/start.sh"
