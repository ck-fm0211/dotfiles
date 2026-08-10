#!/bin/bash
# install_vscode_extensions.sh - Brewfile.vscode の拡張機能を逐次インストール
# brew bundle は並列実行による ENOTEMPTY 競合が起きるため、code --install-extension を順番に呼ぶ

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BREWFILE="$BASE_DIR/.config/homebrew/Brewfile.vscode"

if ! command -v code >/dev/null 2>&1; then
  echo "code コマンドが見つかりません。VSCode をインストールしてから再実行してください。" >&2
  exit 1
fi

if [ ! -f "$BREWFILE" ]; then
  echo "Brewfile.vscode が見つかりません: $BREWFILE" >&2
  exit 1
fi

echo ">>> VSCode 拡張機能をインストールしています..."

# インストール済み拡張機能を一度だけ取得（小文字に正規化）
installed_exts=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')

installed=0
skipped=0
failed=0

while IFS= read -r line || [ -n "$line" ]; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// }" ]] && continue

  if [[ "$line" =~ ^vscode[[:space:]]+\"([^\"]+)\" ]]; then
    ext="${BASH_REMATCH[1]}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    if echo "$installed_exts" | grep -qx "$ext_lower"; then
      echo "  スキップ（インストール済み）: $ext"
      skipped=$((skipped + 1))
    else
      echo "  インストール: $ext"
      if code --install-extension "$ext" --force 2>&1 | tail -1; then
        installed=$((installed + 1))
      else
        echo "  警告: インストール失敗: $ext" >&2
        failed=$((failed + 1))
      fi
    fi
  fi
done < "$BREWFILE"

echo ">>> 完了（インストール: ${installed} 件、スキップ: ${skipped} 件、失敗: ${failed} 件）"
[ "$failed" -eq 0 ]
