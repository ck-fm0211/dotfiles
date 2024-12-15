#!/bin/zsh

# aliases
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
    alias cat="bat"
fi

# date
if type "gdate" > /dev/null 2>&1; then
    alias date="gdate"
fi

# date
if type "gsed" > /dev/null 2>&1; then
    alias sed='gsed'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'

## Applications ##

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# mise activate
eval "$(/opt/homebrew/bin/mise activate zsh)"

# set theme via `starship`
eval "$(starship init zsh)"

# gcloud
if [ -f '/Users/chikafumi/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/chikafumi/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/chikafumi/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/chikafumi/google-cloud-sdk/completion.zsh.inc'; fi

# iterm2
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true
