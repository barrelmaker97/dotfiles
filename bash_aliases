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
alias ll='ls -alhFo'
alias la='ls -A'
alias l='ls -CF'

# tmux session alias
alias mux='tmux new -s Home'

# typing is hard
alias c='clear'
alias update='sudo apt-get -y update && sudo apt-get -y upgrade'

# cleanup git directories
alias glean='find -name "*.git" -type d -exec ~/dotfiles/bin/gitgc.sh "{}" ";"'

# windows aliases
if [ $TERM == "cygwin" ]; then
	alias vim='/c/Program\ Files/Vim/vim81/vim.exe'
	alias view='/c/Program\ Files/Vim/vim81/vim.exe -R'
	alias vimdiff='/c/Program\ Files/Vim/vim81/vim.exe -d'
	alias gvim='/c/Program\ Files/Vim/vim81/gvim.exe'
	alias gview='/c/Program\ Files/Vim/vim81/gvim.exe -R'
	alias gvimdiff='/c/Program\ Files/Vim/vim81/gvim.exe -d'
	fi
