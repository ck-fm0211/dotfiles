#!/bin/bash
set -e

brew bundle dump --force --brews --file="$XDG_CONFIG_HOME/homebrew/Brewfile"
brew bundle dump --force --vscode --file="$XDG_CONFIG_HOME/homebrew/Brewfile.vscode"
brew bundle dump --force --cask --file="$XDG_CONFIG_HOME/homebrew/Brewfile.cask"
brew bundle dump --force --taps --file="$XDG_CONFIG_HOME/homebrew/Brewfile.taps"
brew bundle dump --force --mas --file="$XDG_CONFIG_HOME/homebrew/Brewfile.mas"
