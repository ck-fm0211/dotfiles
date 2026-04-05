#!/bin/zsh
set -e

# https://github.com/zdharma-continuum/zinit
bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
source ~/.zshrc
# zinit self-update
