#!/bin/zsh
# path.zsh - PATH 管理を一元化
# .zshenv に書くと非対話シェルでも実行されるため、
# 対話シェルのみで必要なパスはここで管理する

# ユーザーローカルバイナリ（最優先）
path=("$HOME/.local/bin" "$HOME/.local/bin/scripts" $path)

# Homebrew（Apple Silicon / Intel 自動判定）
if [[ -x /opt/homebrew/bin/brew ]]; then
  path=(/opt/homebrew/bin /opt/homebrew/sbin $path)
elif [[ -x /usr/local/bin/brew ]]; then
  path=(/usr/local/bin /usr/local/sbin $path)
fi

# mise でインストールしたツール
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  path=("$HOME/.local/share/mise/shims" $path)
fi

# Python: pip でインストールしたスクリプト
if [[ -d "$HOME/Library/Python" ]]; then
  for pybin in "$HOME"/Library/Python/*/bin(N); do
    path=("$pybin" $path)
  done
fi

# Go
if [[ -d "$HOME/go/bin" ]]; then
  path=("$HOME/go/bin" $path)
fi

# 重複を除去して export
typeset -U path
export PATH
