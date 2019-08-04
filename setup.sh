#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

set -x

# Color codes for output
RED='\e[01;31m'
YELLOW='\e[01;33m'
GREEN='\e[01;32m'
BLUE='\e[01;34m'
RESET='\e[00m'

usage ()
{
	echo -e "Usage: \n"
	echo -e "\tall\t\t - install all except for work"
	echo -e "\tbash\t\t - install bash configs"
	echo -e "\tgit\t\t - install git configs"
	echo -e "\tvim\t\t - install vim configs"
	echo -e "\ttmux\t\t - install tmux configs"
	echo -e "\twork\t\t - install work configs"
	echo -e "\tusage\t\t - print this message\n"
}

all_install ()
{
	echo -ne "Installing configs... "
	vim_install &
	bash_install &
	git_install &
	tmux_install &
	wait
	echo -e "Done"
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
	vim -E -c PlugUpdate -c quitall >/dev/null 2>&1
}

tmux_install ()
{
	ln -sf "${HOME}"/dotfiles/tmux.conf "${HOME}"/.tmux.conf
}

work_install ()
{
	ln -sf "${HOME}"/dotfiles/work-gitconfig "${HOME}"/.work-gitconfig
}

# Print default usage when run without arguments
if [ "$#" -eq 0 ]; then
	usage
	exit 0
fi

# Action parsing
ACTION="$1"
case "${ACTION}" in
	all|bash|git|work|vim|tmux)
		"${ACTION}"_install
		;;
	usage)
		"${ACTION}"
		;;
	*)
		echo -e "Invalid action '""${ACTION}""' specified."
		usage
		exit 1
		;;
esac
