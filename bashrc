# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# prompt
export PS1='\[\033[36;1m\]`whoami`@`hostname -s` \[\033[32;1m\]\w \$\[\033[36;1m\]\[\033[0m\] '
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias grep='grep --color=auto'
fi

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

EDITOR="vim"
VISUAL="vim"

alias ns='sudo netstat --numeric-ports -elp46 | sort'
alias ls='ls --color=always -l -F'
alias sp='apt-cache search --names-only'
