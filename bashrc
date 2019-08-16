# .bashrc

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
export HISTIGNORE="exit:ls:ll:la:c:clear:cd"
HISTTIMEFORMAT='%F %T '
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# Check window size after each command
shopt -s checkwinsize

# Fix spelling errors in cd
shopt -s cdspell

RED='\[\e[1;31m\]'
ORANGE='\[\e[38;5;208m\]'
YELLOW='\[\e[1;33m\]'
GREEN='\[\e[1;32m\]'
CYAN='\[\e[1;36m\]'
BLUE='\[\e[1;34m\]'
PURPLE='\[\e[1;35m\]'
WHITE='\[\e[1;37m\]'
RESET='\[\e[0m\]'

# Set prompt
git_branch ()
{
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

git_clean ()
{
	if [ -z "$(git status -s)" ]; then
		echo "${CYAN}$(git_branch)"
	else
		echo "${RED}$(git_branch)"
	fi
}

set_prompt ()
{
	local symbol="\$"
	local color="${GREEN}"
	if [ "${HOSTNAME}" = "raspberrypi" ]; then
		color="${PURPLE}"
	fi
	if [ "${USER}" = "root" ]; then
		color="${RED}"
		symbol="#"
	fi

	local git_info=""
	if [ -n "$(git_branch)" ]; then
		git_info="${WHITE} on $(git_clean)"
	fi

	local test_env=""
	if ! [ -z "${VIRTUAL_ENV}" ]; then
		test_env="${YELLOW}[${VIRTUAL_ENV##*/}]${RESET}"
	fi
	PS1="${test_env}${color}\u@\h${WHITE}:${BLUE}\w${git_info}${WHITE}${symbol}${RESET} "
}

PROMPT_COMMAND='set_prompt'

# Alias definitions
if [ -f ~/dotfiles/aliases ]; then
	. ~/dotfiles/aliases
fi

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

# Cycle through options on autocomplete
bind TAB:menu-complete

# Set GPG TTY for commit signing
GPG_TTY=$(tty)
export GPG_TTY
