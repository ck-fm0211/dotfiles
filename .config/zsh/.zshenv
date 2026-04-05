# shellcheck disable=SC2148

# XDG
# https://wiki.archlinux.jp/index.php/XDG_Base_Directory
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache

# homebrew
export PATH=/opt/homebrew/bin:$PATH
export HOMEBREW_BUNDLE_FILE_GLOBAL=$HOME/.config/homebrew/.Brewfile

# aws cli
export AWS_PAGER=""

# docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

# less
export LESSHISTFILE="$XDG_STATE_HOME"/less/history

# python
export PYTHONSTARTUP="$HOME"/python/pythonrc
touch "$XDG_STATE_HOME/python_history"

#bat(cat)
export BAT_THEME="Solarized (dark)"

# 環境変数
export CLICOLOR=1
export LANG=ja_JP.UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad

# PATH
export PATH="$HOME/.local/bin:$HOME/.local/bin/scripts:$PATH"
