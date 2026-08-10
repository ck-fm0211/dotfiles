#!/bin/bash
# npm_global.sh - .config/npm/packages.txt に記載されたグローバル npm パッケージをインストール

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGES_FILE="$BASE_DIR/.config/npm/packages.txt"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm が見つかりません。mise で Node.js をインストールしてから再実行してください。" >&2
  exit 1
fi

if [ ! -f "$PACKAGES_FILE" ]; then
  echo "パッケージリストが見つかりません: $PACKAGES_FILE" >&2
  exit 1
fi

echo ">>> npm グローバルパッケージをインストールしています..."

installed=0
skipped=0

while IFS= read -r line || [ -n "$line" ]; do
  # コメント・空行をスキップ
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// }" ]] && continue

  pkg="$line"

  if npm list -g --depth=0 "$pkg" >/dev/null 2>&1; then
    echo "  スキップ（インストール済み）: $pkg"
    skipped=$((skipped + 1))
  else
    echo "  インストール: $pkg"
    npm install -g "$pkg"
    installed=$((installed + 1))
  fi
done < "$PACKAGES_FILE"

echo ">>> 完了（インストール: ${installed} 件、スキップ: ${skipped} 件）"
