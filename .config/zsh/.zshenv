# shellcheck disable=SC2148

# XDG
# https://wiki.archlinux.jp/index.php/XDG_Base_Directory
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache

# zsh
export HISTFILE="$XDG_STATE_HOME"/zsh/history
# ヒストリに保存するコマンド数
export HISTSIZE=10000
# ヒストリファイルに保存するコマンド数
export SAVEHIST=10000

# homebrew
export PATH=/opt/homebrew/bin:$PATH
export HOMEBREW_BUNDLE_FILE_GLOBAL=$HOME/.config/homebrew/.Brewfile

# starship
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

# aws cli
export AWS_PAGER=""

# docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker

# less
export LESSHISTFILE="$XDG_STATE_HOME"/less/history

# less
export PYTHONSTARTUP="$HOME"/python/pythonrc
touch "$XDG_STATE_HOME/python_history"

# 環境変数
export CLICOLOR=1
export LANG=ja_JP.UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
