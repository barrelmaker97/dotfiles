#!/bin/bash

echo -ne "Checking for git... "
which git >/dev/null
if [ $? -eq 1 ]; then
	echo -e "Git is not installed or cannot be found on this system"
	exit 1
fi
echo -e "Done"

echo -ne "Checking for vim... "
which vim >/dev/null
if [ $? -eq 1 ]; then
	echo -e "Vim is not installed or cannot be found on this system"
	exit 1
fi
echo -e "Done"

cd ~
if [ -d dotfiles ]; then
	echo -ne "Updating local repo... "
	cd dotfiles && git checkout master >/dev/null 2>&1 && git pull >/dev/null 2>&1
	echo -e "Done"
else
	echo -e "Cloning repo.. "
	git clone https://github.com/barrelmaker97/dotfiles >/dev/null 2>&1
	cd dotfiles
	echo -e "Done"
fi
./setup.sh all
