# .bash_aliases

# ssh aliases
alias tiger='ssh z1766022@tiger.cs.niu.edu'
alias hopper='ssh z1766022@hopper.cs.niu.edu'
alias hartley='ssh z1766022@hartley.cs.niu.edu'
alias pi='ssh pi@10.157.1.156'

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

# sql
alias mysql='mysql -h courses -u z1766022 -p z1766022'

# cleanup git directories
alias glean='find -name "*.git" -type d -exec ~/dotfiles/bin/gitgc.sh "{}" ";"'

# windows aliases
if [ $TERM == "cygwin" ]; then
	alias vim='/c/Program\ Files\ \(x86\)/Vim/vim81/gvim.exe'
	alias view='/c/Program\ Files\ \(x86\)/Vim/vim81/gvim.exe -R'
	alias vimdiff='/c/Program\ Files\ \(x86\)/Vim/vim81/gvim.exe -d'
	alias gvim='/c/Program\ Files\ \(x86\)/Vim/vim81/gvim.exe'
	alias gvimdiff='/c/Program\ Files\ \(x86\)/Vim/vim81/gvim.exe -d'
	fi
