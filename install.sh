#!/bin/bash

# Color codes for output
RED='\e[01;31m'
YELLOW='\e[01;33m'
GREEN='\e[01;32m'
BLUE='\e[01;34m'
RESET='\e[00m'

check_dependencies ()
{
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
}

clone_or_update_repo ()
{
	cd ~
	if [ -d dotfiles ]; then
		echo -ne "Updating local repo... "
		cd dotfiles \
			&& git checkout master >/dev/null 2>&1 \
			&& git pull >/dev/null 2>&1
		echo -e "Done"
	else
		echo -ne "Cloning repo... "
		git clone https://github.com/barrelmaker97/dotfiles >/dev/null 2>&1
		cd dotfiles
		echo -e "Done"
	fi
}

update_install ()
{
	check_dependencies
	clone_or_update_repo
	all_install
}

all_install ()
{
	echo -ne "Installing configs... "
	bash_install & git_install & tmux_install & vim_install
	wait && echo -e "Done"
}

bash_install ()
{
	ln -sf "${HOME}"/dotfiles/bashrc "${HOME}"/.bashrc
	ln -sf "${HOME}"/dotfiles/profile "${HOME}"/.profile
}

git_install ()
{
	ln -sf "${HOME}"/dotfiles/gitconfig "${HOME}"/.gitconfig
}

vim_install ()
{
	ln -sf "${HOME}"/dotfiles/vimrc "${HOME}"/.vimrc
	rm -rf ~/.vim
	curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	yes "" | vim +PlugInstall +quitall >/dev/null 2>&1
}

tmux_install ()
{
	ln -sf "${HOME}"/dotfiles/tmux.conf "${HOME}"/.tmux.conf
}

work_install ()
{
	ln -sf "${HOME}"/dotfiles/work-gitconfig "${HOME}"/.work-gitconfig
}

help ()
{
	echo -e "Usage: \n"
	echo -e "\tall\t\t - install all except for work"
	echo -e "\tbash\t\t - install bash configs"
	echo -e "\tgit\t\t - install git configs"
	echo -e "\tvim\t\t - install vim configs"
	echo -e "\ttmux\t\t - install tmux configs"
	echo -e "\twork\t\t - install work configs"
	echo -e "\thelp\t\t - print this message\n"
}

# Print default help when run without arguments
if [ "$#" -eq 0 ]; then
	update_install
	exit 0
fi

# Action parsing
ACTION="$1"
case "${ACTION}" in
	all|bash|git|work|vim|tmux)
		"${ACTION}"_install
		;;
	help)
		"${ACTION}"
		;;
	*)
		echo -e "Invalid action '${ACTION}' specified."
		help
		exit 1
		;;
esac
