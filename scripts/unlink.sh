#!/bin/bash
# unlink.sh - link_map.yaml で作成したシンボリックリンクをすべて削除する
#
# オプション:
#   --dry-run   実際には削除せずに対象を表示するだけ
#   --restore   backup.sh で作ったバックアップから元のファイルを復元する

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LINK_MAP="$BASE_DIR/.config/link_map.yaml"
DRY_RUN=0
RESTORE=0
RESTORE_DIR=""

# ----------- 色付きログ -----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  GREEN="$(tput setaf 2)"; RED="$(tput setaf 1)"
  YELLOW="$(tput setaf 3)"; BOLD="$(tput bold)"; RESET="$(tput sgr0)"
else
  GREEN=""; RED=""; YELLOW=""; BOLD=""; RESET=""
fi

log()  { echo "${BOLD}$*${RESET}"; }
ok()   { echo "  ${GREEN}✓${RESET} $*"; }
skip() { echo "  ${YELLOW}-${RESET} $*"; }
fail() { echo "  ${RED}✗${RESET} $*" >&2; }

# ----------- オプション解析 -----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --restore)
      RESTORE=1
      shift
      RESTORE_DIR="${1:-}"
      if [ -z "$RESTORE_DIR" ]; then
        # 最新のバックアップディレクトリを自動検出
        RESTORE_DIR=$(find "$HOME/.dotfiles-backup" -maxdepth 1 -type d | sort | tail -1)
        if [ -z "$RESTORE_DIR" ]; then
          echo "Error: バックアップが見つかりません。backup.sh を先に実行してください。" >&2
          exit 1
        fi
        echo "バックアップディレクトリを自動検出: $RESTORE_DIR"
      fi
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

command -v yq >/dev/null 2>&1 || { echo "Error: yq が必要です。" >&2; exit 1; }

[ "$DRY_RUN" -eq 1 ] && log "=== DRY RUN モード（実際には変更しません）==="

removed=0
skipped=0
restored=0

remove_symlink() {
  local dst="$1"
  local dst_full="$HOME/$dst"

  if [ -L "$dst_full" ]; then
    local target
    target=$(readlink "$dst_full")
    if [[ "$target" == "$BASE_DIR"* ]]; then
      if [ "$DRY_RUN" -eq 1 ]; then
        ok "[DRY] 削除対象: $dst_full"
      else
        rm "$dst_full"
        ok "削除: $dst_full"
      fi
      removed=$((removed+1))

      # --restore が指定されていれば元ファイルを復元
      if [ "$RESTORE" -eq 1 ] && [ -n "$RESTORE_DIR" ]; then
        local backup_path="$RESTORE_DIR/$dst"
        if [ -e "$backup_path" ]; then
          if [ "$DRY_RUN" -eq 0 ]; then
            cp -R "$backup_path" "$dst_full"
            ok "復元: $backup_path -> $dst_full"
          else
            ok "[DRY] 復元対象: $backup_path -> $dst_full"
          fi
          restored=$((restored+1))
        fi
      fi
    else
      skip "管理外シンボリックリンクのためスキップ: $dst_full -> $target"
      skipped=$((skipped+1))
    fi
  elif [ -e "$dst_full" ]; then
    skip "シンボリックリンクではないためスキップ: $dst_full"
    skipped=$((skipped+1))
  else
    skip "存在しないためスキップ: $dst_full"
    skipped=$((skipped+1))
  fi
}

apps=$(yq eval 'keys | .[]' "$LINK_MAP")
for app in $apps; do
  items=$(yq eval ".$app" "$LINK_MAP")
  if [[ $(yq eval 'type' <<< "$items") == "!!seq" ]]; then
    for pair in $(echo "$items" | yq eval '.[] | @json' -); do
      dst=$(echo "$pair" | yq eval '.dst' -)
      remove_symlink "$dst"
    done
  else
    dst=$(yq eval '.dst' <<< "$items")
    remove_symlink "$dst"
  fi
done

echo ""
log "完了: $removed 件削除、$skipped 件スキップ$([ "$restored" -gt 0 ] && echo "、$restored 件復元" || true)"
