#!/bin/zsh

# ls
if type "eza" > /dev/null 2>&1; then
    alias ls='eza --group-directories-first'
    alias l='eza -F --group-directories-first'
    alias la='eza -a --group-directories-first'
    alias ll='eza -l --git --group-directories-first'
    alias lla='eza -la --git --group-directories-first'
    alias lt='eza --tree --level=2 --group-directories-first'
else
    alias ls='ls'
    alias l='ls -CF'
    alias la='ls -A'
    alias ll='ls -lh'
    alias lla='ls -lAh'
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

# 安全な操作（上書き確認）
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'

# ディレクトリ操作
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# よく使うコマンドの短縮
alias g='git'
alias mk='make'
alias h='history'
alias path='echo $PATH | tr ":" "\n"'

# ネットワーク
alias myip='curl -s https://checkip.amazonaws.com'

# macOS 向け
alias finder='open .'
alias trash='rmtrash'
