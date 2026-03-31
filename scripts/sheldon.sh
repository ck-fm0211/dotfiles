#!/bin/bash

set -euo pipefail

SHELDON_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon"
export SHELDON_CONFIG_DIR

if ! command -v sheldon >/dev/null 2>&1; then
  echo "エラー: sheldon がインストールされていません。" >&2
  exit 1
fi

echo ">>> sheldon プラグインをロックしています..."
sheldon lock
echo ">>> sheldon lock が完了しました。"
