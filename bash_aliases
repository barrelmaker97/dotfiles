# .bash_aliases

# ssh aliases
alias tiger='ssh z1766022@tiger.cs.niu.edu'
alias hopper='ssh z1766022@hopper.cs.niu.edu'

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

#sql
alias mysql='mysql -h courses -u z1766022 -p z1766022'
