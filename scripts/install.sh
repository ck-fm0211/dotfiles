#!/bin/zsh
set -e

# rosetta
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> $HOME/.zshrc
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version
echo 'export PATH=/opt/homebrew/bin:$PATH' >> $HOME/.zshrc

# XDG
echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zshenv
sudo chmod 444 /etc/zshenv

# セットアップに必要なものだけ先にいれる
brew install yq
