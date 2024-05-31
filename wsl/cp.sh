#!/bin/bash
if [ -n "$SUDO_USER" ]
then
    cp -f ./.custom_top /home/$SUDO_USER/.custom_top
    cp -f ./.bash_custom /home/$SUDO_USER/.bash_custom
    cp -f ./.config/zsh/.custom /home/$SUDO_USER/.config/zsh/.custom
    cp -f ./etc/fonts/local.conf /etc/fonts/local.conf
fi
