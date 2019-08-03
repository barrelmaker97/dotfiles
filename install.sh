#!/bin/bash

which git
if [ $? -eq 1 ]; then
	echo -e "Git is not installed or cannot be found on this system"
	exit 1
fi

cd ~
if [ -d dotfiles ]; then
	cd dotfiles && git checkout master && git pull
else
	git clone https://github.com/barrelmaker97/dotfiles
	cd dotfiles
fi
./setup.sh all
