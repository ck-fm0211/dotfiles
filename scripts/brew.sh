#!/bin/zsh
set -e

export HOMEBREW_BUNDLE_FILE_GLOBAL=$HOME/.config/homebrew/.Brewfile
brew bundle --global
