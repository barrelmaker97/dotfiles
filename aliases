# .bash_aliases

# ls and grep color support
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi

# more ls aliases
alias ll='ls -ahFo --time-style=+"%m-%d-%Y %H:%M:%S"'
alias la='ls -AF'
alias l='ls -F'

# print $PATH nicely
alias path='echo $PATH | tr ":" "\n" | sort'

# moving around
alias ..='cd ..'
alias back='cd -'

# tmux session alias
alias mux='tmux new -s Home'

# cleanup git directories
alias glean='find -name "*.git" -type d -exec $HOME/dotfiles/bin/gitgc.sh "{}" ";"'

# windows aliases
if [ $TERM == "cygwin" ]; then
	alias vim='/c/Program\ Files/Vim/vim81/vim.exe'
	alias view='/c/Program\ Files/Vim/vim81/vim.exe -R'
	alias vimdiff='/c/Program\ Files/Vim/vim81/vim.exe -d'
	alias gvim='/c/Program\ Files/Vim/vim81/gvim.exe'
	alias gview='/c/Program\ Files/Vim/vim81/gvim.exe -R'
	alias gvimdiff='/c/Program\ Files/Vim/vim81/gvim.exe -d'
fi
