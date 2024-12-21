#!/bin/bash
set -e

# rosetta
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

# XDG
mkdir -p "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" "$HOME/.local/state"
echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zshenv
sudo chmod 444 /etc/zshenv

# brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
mkdir -p "$HOME/.config/zsh"
echo >> "$HOME/.config/zsh/.zshrc"
# shellcheck disable=SC2016
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.config/zsh/.zshrc"
# shellcheck disable=SC2016
eval "$(/opt/homebrew/bin/brew shellenv)"
brew --version
# shellcheck disable=SC2016
echo 'export PATH=/opt/homebrew/bin:$PATH' >> "$HOME/.config/zsh/.zshrc"

# セットアップに必要なものだけ先にいれる
brew install yq
