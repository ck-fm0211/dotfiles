#!/bin/bash
# brew_dumps.sh - 現在の Homebrew インストール状態を Brewfile にバックアップ

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/homebrew"

echo ">>> Homebrew の状態を $CONFIG_DIR にエクスポートします..."

brew bundle dump --force --brews   --file="$CONFIG_DIR/Brewfile"
echo "    ✓ Brewfile"

brew bundle dump --force --cask    --file="$CONFIG_DIR/Brewfile.cask"
echo "    ✓ Brewfile.cask"

brew bundle dump --force --taps    --file="$CONFIG_DIR/Brewfile.taps"
echo "    ✓ Brewfile.taps"

brew bundle dump --force --mas     --file="$CONFIG_DIR/Brewfile.mas"
echo "    ✓ Brewfile.mas"

brew bundle dump --force --vscode  --file="$CONFIG_DIR/Brewfile.vscode"
echo "    ✓ Brewfile.vscode"

echo ""
echo ">>> エクスポート完了。変更をコミットして管理してください:"
echo "    git -C \$(git rev-parse --show-toplevel) add .config/homebrew/ && git commit -m 'brew: update Brewfiles'"
