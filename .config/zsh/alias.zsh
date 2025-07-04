#!/bin/zsh

# ls
if type "eza" > /dev/null 2>&1; then
    alias ls='eza'
    alias l='eza -F'
    alias la='eza -a'
    alias ll='eza -l'
else
    alias ls='ls'
    alias l='ls -CF'
    alias la='ls -A'
    alias ll='ls -l'
fi

# cat
if type "bat" > /dev/null 2>&1; then
    alias cat="bat --style=plain"
fi

# date
if type "gdate" > /dev/null 2>&1; then
    alias date="gdate"
fi

# sed
if type "gsed" > /dev/null 2>&1; then
    alias sed='gsed'
fi

# diff
if type "colordiff" > /dev/null 2>&1; then
    alias diff='colordiff'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
