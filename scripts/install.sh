#!/bin/bash
set -euo pipefail

# ----- Rosetta (Apple Silicon のみ) -----
if [[ "$(uname -m)" == "arm64" ]]; then
  if pkgutil --pkg-info=com.apple.pkg.RosettaUpdateAuto > /dev/null 2>&1; then
    echo ">>> Rosetta is already installed. Skipping."
  else
    echo ">>> Installing Rosetta..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
  fi
fi

# ----- XDG Base Directory -----
echo ">>> Creating XDG directories..."
mkdir -p "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" "$HOME/.local/state"
mkdir -p "$HOME/.cache/zsh" "$HOME/.local/state/zsh" "$HOME/.local/state/less" "$HOME/.local/state/python"

# GPG ホームディレクトリ（GNUPGHOME=$XDG_DATA_HOME/gnupg を想定）
# gpg は 700 でないと警告 or エラーになる
mkdir -p "$HOME/.local/share/gnupg"
chmod 700 "$HOME/.local/share/gnupg"

# ZDOTDIR を /etc/zshenv に設定（未設定の場合のみ追加）
if ! grep -q "ZDOTDIR" /etc/zshenv 2>/dev/null; then
  echo "export ZDOTDIR=$HOME/.config/zsh" | sudo tee -a /etc/zshenv
fi

# ----- Homebrew -----
if ! command -v brew > /dev/null 2>&1; then
  echo ">>> Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon / Intel で Homebrew のパスが異なる
if [[ "$(uname -m)" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

mkdir -p "$HOME/.config/zsh"

# shellcheck disable=SC2016
eval "$($BREW_PREFIX/bin/brew shellenv)"
brew --version

# ----- セットアップに必要なツール -----
echo ">>> Installing yq..."
brew install yq

echo ">>> install.sh completed successfully."
