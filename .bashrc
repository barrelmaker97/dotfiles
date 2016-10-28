# .bashrc

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# Don't put duplicate lines or lines starting with space in history file
HISTCONTROL=ignoreboth

# Append to history file, don't overwrite
shopt -s histappend

# Set history options
export HISTIGNORE="exit:ls:ll:la:c:clear:cd"
HISTTIMEFORMAT='%F %T '
HISTSIZE=1000
HISTFILESIZE=2000

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

Red='\[\e[01;31m\]'
Green='\[\e[01;32m\]'
Yellow='\[\e[01;33m\]'
Blue='\[\e[01;34m\]'
Cyan='\[\e[01;36m\]'
White='\[\e[01;37m\]'
Reset='\[\e[00m\]'

parse_git_branch()
{
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

parse_git_dirty()
{
	if [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]]; then
		echo "$Yellow$(parse_git_branch)"
	else
		echo "$Cyan$(parse_git_branch)"
	fi
}

set_prompt ()
{
	PS1="$Green\u@\h$White:$Blue\w"
	if [ -n "$(parse_git_branch)" ]; then
		PS1+="$White on $(parse_git_dirty)"
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
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
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

# Set PATH to include current directory
PATH=".:${PATH}"

# Set TERM to support colors
TERM='xterm-256color'
