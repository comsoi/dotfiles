#! /usr/bin/env bash

sudo mkdir -p /mnt/wsl/Mint21
wsl.exe -d Mint21 -u root mount --bind / /mnt/wsl/Mint21/