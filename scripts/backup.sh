#!/bin/bash
# backup.sh - link.sh が上書きするファイルを事前にバックアップ

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LINK_MAP="$BASE_DIR/.config/link_map.yaml"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/$TIMESTAMP"

command -v yq >/dev/null 2>&1 || { echo "Error: yq が必要です。brew install yq でインストールしてください。" >&2; exit 1; }

echo "バックアップ先: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

backed_up=0
skipped=0

backup_file() {
  local dst="$1"
  local dst_full="$HOME/$dst"

  # シンボリックリンクでも実ファイルでもなければスキップ
  if [ ! -e "$dst_full" ] && [ ! -L "$dst_full" ]; then
    return
  fi

  # すでにこのリポジトリへのシンボリックリンクならスキップ
  if [ -L "$dst_full" ]; then
    local target
    target=$(readlink "$dst_full")
    if [[ "$target" == "$BASE_DIR"* ]]; then
      skipped=$((skipped+1))
      return
    fi
  fi

  local backup_path="$BACKUP_DIR/$dst"
  mkdir -p "$(dirname "$backup_path")"
  cp -R "$dst_full" "$backup_path"
  echo "  backed up: ~/$dst -> $backup_path"
  backed_up=$((backed_up+1))
}

apps=$(yq eval 'keys | .[]' "$LINK_MAP")
for app in $apps; do
  items=$(yq eval ".$app" "$LINK_MAP")

  if [[ $(yq eval 'type' <<< "$items") == "!!seq" ]]; then
    while IFS= read -r pair; do
      dst=$(echo "$pair" | yq eval '.dst' -)
      backup_file "$dst"
    done < <(echo "$items" | yq eval '.[] | @json' -)
  else
    dst=$(yq eval '.dst' <<< "$items")
    backup_file "$dst"
  fi
done

echo ""
echo "完了: $backed_up ファイルをバックアップしました（$skipped 件はスキップ）"
echo "バックアップ先: $BACKUP_DIR"
echo ""
echo "リストア方法:"
echo "  cp -R $BACKUP_DIR/. \$HOME/"
