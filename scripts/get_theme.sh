#!/bin/bash
if [[ -z Tela-icon-theme ]]; then
	git clone git@github.com:vinceliuice/Tela-icon-theme.git
else
	cd Tela-icon-theme
	git pull
	cd ..
fi
if [[ -z WhiteSur-icon-theme ]]; then
	git clone git@github.com:vinceliuice/WhiteSur-icon-theme.git
else
	cd WhiteSur-icon-theme
	git pull
	cd ..
fi
if [[ -z Colloid-icon-theme ]]; then
	git clone git@github.com:vinceliuice/Colloid-icon-theme.git
else
	cd Colloid-icon-theme
	git pull
	cd ..
fi
if [[ -z Graphite-kde-theme ]]; then
	git clone git@github:vinceliuice/Graphite-kde-theme.git
else
	cd Graphite-kde-theme
	git pull
	cd ..
fi
if [[ -z grub2-themes ]]; then
	git clone git@github.com:vinceliuice/grub2-themes.git
else
	cd grub2-themes
	git pull
	cd ..
fi

./Tela-icon-theme/install.sh -c
./WhiteSur-icon-theme/install.sh -a -b
./Colloid-icon-theme/install.sh -s catppuccin
./Graphite-kde-theme/install.sh
sudo ./grub2-themes/install.sh -c 2560x1600 -s 2k --theme vimix
