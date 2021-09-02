# .bashrc
# vim: ft=bash :

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# Set umask if it isn't already
umask 022

# History options
shopt -s histappend
shopt -s cmdhist
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
HISTCONTROL=ignorespace:ignoredups
HISTSIZE=100000
HISTFILESIZE=$HISTSIZE

# Check window size after each command
shopt -s checkwinsize

# Fix spelling errors in cd
shopt -s cdspell

# Standard Colors
RED='\[\e[0;31m\]'
YELLOW='\[\e[0;33m\]'
GREEN='\[\e[0;32m\]'
CYAN='\[\e[0;36m\]'
BLUE='\[\e[0;34m\]'
PURPLE='\[\e[0;35m\]'
WHITE='\[\e[0;37m\]'
BR_RED='\[\e[0;91m\]'
BR_YELLOW='\[\e[0;93m\]'
BR_GREEN='\[\e[0;92m\]'
BR_CYAN='\[\e[0;96m\]'
BR_BLUE='\[\e[0;94m\]'
BR_PURPLE='\[\e[0;95m\]'
BR_WHITE='\[\e[0;97m\]'
RESET='\[\e[0m\]'

# Expanded colors
ORANGE='\[\e[38;5;208m\]'
GOLD='\[\e[38;5;220m\]'
TEAL='\[\e[38;5;51m\]'
SLATE='\[\e[38;5;115m\]'
LIME='\[\e[38;5;46m\]'

set_prompt ()
{
	case "${HOSTNAME}" in
		"ares")
			local color="${GOLD}";;
		"pollux")
			local color="${ORANGE}";;
		"zeus")
			local color="${TEAL}";;
		"hephaestus")
			local color="${SLATE}";;
		"soteria")
			local color="${LIME}";;
		*)
			local color="${BR_GREEN}";;
	esac

	local symbol="\$"
	if [ "${USER}" = "root" ]; then
		color="${BR_RED}"
		symbol="#"
	fi

	local git_info
	local current_branch
	current_branch="$(git rev-parse --abbrev-ref HEAD 2> /dev/null)"
	if [ -n "$current_branch" ]; then
		if [ -z "$(git status -s)" ]; then
			local git_color="${BR_CYAN}"
		else
			local git_color="${BR_RED}"
		fi
		git_info="${BR_WHITE} on ${git_color}${current_branch}"
	fi

	local test_env
	if [ -n "${VIRTUAL_ENV}" ]; then
		test_env="${BR_YELLOW}[${VIRTUAL_ENV##*/}]${RESET}"
	fi
	PS1="${test_env}${color}\u@\h${BR_WHITE}:${BR_BLUE}\w${git_info}${BR_WHITE}${symbol}${RESET} "
}

PROMPT_COMMAND='set_prompt'

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# Set PATH to include private bin if it exists
if [ -d "$HOME/bin" ] ; then
	PATH="$HOME/bin:$PATH"
fi

# Add Tex Live to PATH
if [ -d "/usr/local/texlive/2020/bin/x86_64-linux" ] ; then
	PATH="/usr/local/texlive/2020/bin/x86_64-linux:$PATH"
fi

# Add local Python packages to PATH
if [ -d "$HOME/.local/bin" ] ; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Cycle through options on autocomplete
bind TAB:menu-complete

# Set GPG TTY for commit signing
export GPG_TTY=$(tty)

# Set fc editor
export FCEDIT=vim

# kubectl completion
command -v kubectl > /dev/null && source <(kubectl completion bash)

# oc completion
command -v oc > /dev/null && source <(oc completion bash)

# helm completion
command -v helm > /dev/null && source <(helm completion bash)

# fly completion
command -v fly > /dev/null && source <(fly completion --shell bash)

# Alias definitions; Keep this at the bottom
if [ -f ~/dotfiles/aliases ]; then
	. ~/dotfiles/aliases
fi
