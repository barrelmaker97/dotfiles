# dotfiles
Backup for my dotfiles.

## Installation
* The easiest way to install is to run `curl -sSL dotfiles.barrelmaker.dev | bash`. This will install all of the dotfiles into your home directory (minus my work configs).
* If you don't want to pipe someone else's code directly into bash (understandably so), then you can clone this repo and run `./bin/updot` to install all of the dotfiles into your home directory (minus my work configs). Running `./bin/updot help` will show you individual dotfile installation options.

Fair warning: The installation will silently overwrite your existing dotfiles.

## Requirements
* Git
* Vim >= 8.0
* 24-bit color support in terminal (including tmux)
* Tmux >= 2.2

# License

Copyright (c) 2021 Nolan Cooper

This dotfiles collection is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This dotfiles collection is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this dotfiles collection.  If not, see <https://www.gnu.org/licenses/>.
