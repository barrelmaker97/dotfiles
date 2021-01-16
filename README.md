# dotfiles
Backup for my dotfiles.

## Installation
* The easiest way to install is to run `curl -sSL dotfiles.barrelmaker.dev | bash`. This will install all of the dotfiles into your home directory (minus my work configs).
* If you don't want to pipe someone else's code directly into bash (understandably so), then you can clone this repo and run `./bin/updot` to install all of the dotfiles into your home directory (minus my work configs). Running `./bin/updot help` will show you individual dotfile installation options.

Fair warning: The installation will silently overwrite your existing dotfiles.

## Requirements
* Git
* Vim
* 24-bit color support in terminal (including tmux)
* Tmux 2.2 or higher
