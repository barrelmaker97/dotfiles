ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all:
	@printf "Makefile targets: \n\n"
	@printf "\tinstall\t\t - install all except for work\n"
	@printf "\tbash\t\t - install bash configs\n"
	@printf "\tgit\t\t - install git configs\n"
	@printf "\twork\t\t - install work configs\n"
	@printf "\tvim\t\t - install vim configs\n"
	@printf "\ttmux\t\t - install tmux configs\n"
	@printf "\thelp\t\t - print this message\n\n"

install: bash git vim tmux

bash:
	ln -sf $(ROOT_DIR)/bashrc $(HOME)/.bashrc
	ln -sf $(ROOT_DIR)/bash_aliases $(HOME)/.bash_aliases
	ln -sf $(ROOT_DIR)/profile $(HOME)/.profile
git:
	ln -sf $(ROOT_DIR)/gitconfig $(HOME)/.gitconfig
	ln -sf $(ROOT_DIR)/gitignore $(HOME)/.gitignore
work:
	ln -sf $(ROOT_DIR)/work-gitconfig $(HOME)/.work-gitconfig
vim:
	ln -sf $(ROOT_DIR)/vimrc $(HOME)/.vimrc
	rm -rf ~/.vim
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	vim -c PlugInstall -c quitall
tmux:
	ln -sf $(ROOT_DIR)/tmux.conf $(HOME)/.tmux.conf
help: all
