# XDG
# https://wiki.archlinux.jp/index.php/XDG_Base_Directory
export XDG_DATA_HOME=$HOME/.local/share/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_STATE_HOME=$HOME/.local/state/
export XDG_CACHE_HOME=$HOME/.cache

# homebrew
export PATH=/opt/homebrew/bin:$PATH
export HOMEBREW_BUNDLE_FILE_GLOBAL=$HOME/.config/homebrew/.Brewfile

# starship
export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

# aws cli
export AWS_PAGER=""

# 環境変数
export CLICOLOR=1
export LANG=ja_JP.UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad
