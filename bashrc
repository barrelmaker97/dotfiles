# .bashrc

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

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

Red='\e[01;31m'
Orange='\e[38;5;208m'
Yellow='\e[01;33m'
Green='\e[01;32m'
Cyan='\e[01;36m'
Blue='\e[01;34m'
Purple='\e[01;35m'
White='\e[01;37m'
Reset='\e[00m'

# Set prompt
git_branch ()
{
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

git_clean ()
{
	if [ -z "$(git status -s)" ]; then
		echo "$Cyan$(git_branch)"
	else
		echo "$Red$(git_branch)"
	fi
}

set_prompt ()
{
	if [ "$HOSTNAME" = "raspberrypi" ]; then
		PS1="$Purple\u@\h$White:$Blue\w"
	else
		PS1="$Green\u@\h$White:$Blue\w"
	fi
	if [ -n "$(git_branch)" ]; then
		PS1="$PS1$White on $(git_clean)"
	fi
	if ! [ -z "$VIRTUAL_ENV" ]; then
		TEST_ENV="[${VIRTUAL_ENV##*/}]"
		PS1="$Yellow$TEST_ENV$Reset$PS1"
	fi
	PS1+="$White\$ $Reset"
}

PROMPT_COMMAND='set_prompt'

# If this is an xterm set title to user@host:dir
case "$TERM" in
	xterm*|rxvt*)
		PS1="\[\e]0;\u@\h: \w\a\]$PS1"
		;;
	*)
		;;
esac

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
