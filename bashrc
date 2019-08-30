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

RED='\[\e[0;31m\]'
ORANGE='\[\e[38;5;208m\]'
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

# Set prompt
git_branch ()
{
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

git_clean ()
{
	if [ -z "$(git status -s)" ]; then
		echo "${BR_CYAN}$(git_branch)"
	else
		echo "${BR_RED}$(git_branch)"
	fi
}

set_prompt ()
{
	local symbol="\$"
	local color="${BR_GREEN}"
	if [ "${HOSTNAME}" = "castor" ]; then
		color="${BR_YELLOW}"
	fi
	if [ "${HOSTNAME}" = "pollux" ]; then
		color="${ORANGE}"
	fi
	if [ "${USER}" = "root" ]; then
		color="${BR_RED}"
		symbol="#"
	fi

	local git_info=""
	if [ -n "$(git_branch)" ]; then
		git_info="${BR_WHITE} on $(git_clean)"
	fi

	local test_env=""
	if ! [ -z "${VIRTUAL_ENV}" ]; then
		test_env="${BR_YELLOW}[${VIRTUAL_ENV##*/}]${RESET}"
	fi
	PS1="${test_env}${color}\u@\h${BR_WHITE}:${BR_BLUE}\w${git_info}${BR_WHITE}${symbol}${RESET} "
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

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh
