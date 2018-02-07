ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all:
	@printf "Makefile targets: \n\n"
	@printf "\tinstall\t\t - install all\n"
	@printf "\tbash\t\t - install bash\n"
	@printf "\tgit\t\t - install git\n"
	@printf "\tvim\t\t - install vim\n"
	@printf "\ttmux\t\t - install tmux\n"
	@printf "\thelp\t\t - print this message\n\n"

install: bash git vim tmux

bash:
	ln -sf $(ROOT_DIR)/bashrc $(HOME)/.bashrc
	ln -sf $(ROOT_DIR)/bash_aliases $(HOME)/.bash_aliases
	ln -sf $(ROOT_DIR)/profile $(HOME)/.profile
git:
	ln -sf $(ROOT_DIR)/gitconfig $(HOME)/.gitconfig
	ln -sf $(ROOT_DIR)/gitignore $(HOME)/.gitignore
vim:
	ln -sf $(ROOT_DIR)/vimrc $(HOME)/.vimrc
	rm -rf ~/.vim
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	vim -c PlugInstall -c quitall
tmux:
	ln -sf $(ROOT_DIR)/tmux.conf $(HOME)/.tmux.conf
help: all
