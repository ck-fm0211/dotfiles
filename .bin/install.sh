#!/bin/zsh
set -e

# rosetta
sudo softwareupdate --install-rosetta

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> $HOME/.zshrc
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version

echo 'export PATH=/opt/homebrew/bin:$PATH' >> $HOME/.zshrc

brew bundle --global
