#!/bin/bash

# Color codes for output
RED='\e[1;31m'
YELLOW='\e[1;33m'
GREEN='\e[1;32m'
BLUE='\e[1;34m'
RESET='\e[0m'

TICK="[${GREEN}✓${RESET}]"
CROSS="[${RED}✗${RESET}]"
INFO="[i]"
DONE="${GREEN} done!${RESET}"

check_dependencies ()
{
	echo -ne " ${INFO} Checking for git"
	which git >/dev/null
	if [ $? -eq 1 ]; then
		echo -e "\r ${CROSS}"
		echo -e "Git is not installed or cannot be found on this system"
		exit 1
	fi
	echo -e "\r ${TICK}"

	echo -ne " ${INFO} Checking for vim"
	which vim >/dev/null
	if [ $? -eq 1 ]; then
		echo -e "\r ${CROSS}"
		echo -e "Vim is not installed or cannot be found on this system"
		exit 1
	fi
	echo -e "\r ${TICK}"
}

clone_or_update_repo ()
{
	cd ~
	if [ -d dotfiles ]; then
		echo -ne " ${INFO} Updating local repo"
		cd dotfiles \
			&& git checkout master >/dev/null 2>&1 \
			&& git pull >/dev/null 2>&1
		echo -e "\r ${TICK}"
	else
		echo -ne " ${INFO} Cloning repo"
		git clone https://github.com/barrelmaker97/dotfiles >/dev/null 2>&1
		cd dotfiles
		echo -e "\r ${TICK}"
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
	bash_install
	git_install
	tmux_install
	i3_install
	urxvt_install
	vim_install
}

bash_install ()
{
	echo -ne " ${INFO} Installing bash configs"
	ln -sf "${HOME}"/dotfiles/bashrc "${HOME}"/.bashrc
	ln -sf "${HOME}"/dotfiles/profile "${HOME}"/.profile
	. "${HOME}"/dotfiles/bashrc
	echo -e "\r ${TICK}"
}

git_install ()
{
	echo -ne " ${INFO} Installing git configs"
	ln -sf "${HOME}"/dotfiles/gitconfig "${HOME}"/.gitconfig
	echo -e "\r ${TICK}"
}

vim_install ()
{
	echo -ne " ${INFO} Installing vim configs"
	ln -sf "${HOME}"/dotfiles/vimrc "${HOME}"/.vimrc
	rm -rf ~/.vim
	curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	yes "" | vim +PlugInstall +quitall >/dev/null 2>&1
	echo -e "\r ${TICK}"
}

tmux_install ()
{
	echo -ne " ${INFO} Installing tmux configs"
	ln -sf "${HOME}"/dotfiles/tmux.conf "${HOME}"/.tmux.conf
	echo -e "\r ${TICK}"
}

work_install ()
{
	echo -ne " ${INFO} Installing work configs"
	ln -sf "${HOME}"/dotfiles/work-gitconfig "${HOME}"/.work-gitconfig
	echo -e "\r ${TICK}"
}

i3_install ()
{
	echo -ne " ${INFO} Installing i3 configs"
	ln -sf "${HOME}"/dotfiles/i3config "${HOME}"/.config/i3/config
	echo -e "\r ${TICK}"
}

urxvt_install ()
{
	echo -ne " ${INFO} Installing urxvt configs"
	ln -sf "${HOME}"/dotfiles/xresources "${HOME}"/.Xresources
	echo -e "\r ${TICK}"
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

# Install all when run without arguments
if [ "$#" -eq 0 ]; then
	update_install
	exit 0
fi

# Action parsing
ACTION="$1"
case "${ACTION}" in
	all|bash|git|work|vim|tmux|i3|urxvt)
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
