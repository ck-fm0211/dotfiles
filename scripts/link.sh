#!/bin/bash
# link.sh - link_map.yaml に基づきシンボリックリンクを作成する
#
# オプション:
#   --dry-run    実際には作成せずに対象を表示するだけ
#   --verbose    詳細なログを表示

set -euo pipefail

DRY_RUN=0
VERBOSE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --verbose) VERBOSE=1 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# ----------- 色付きログ -----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"
  RED="$(tput setaf 1)"; BOLD="$(tput bold)"; RESET="$(tput sgr0)"
else
  GREEN=""; YELLOW=""; RED=""; BOLD=""; RESET=""
fi

ok()   { echo "  ${GREEN}✓${RESET} $*"; }
warn() { echo "  ${YELLOW}!${RESET} $*" >&2; }
skip() { [ "$VERBOSE" -eq 1 ] && echo "  ${YELLOW}-${RESET} $*" || true; }
fail() { echo "  ${RED}✗${RESET} $*" >&2; }
log()  { echo "${BOLD}$*${RESET}"; }

# ----------- 必要なコマンドの確認 -----------
command -v yq >/dev/null 2>&1 || { echo "Error: yq is not installed. Please install it first." >&2; exit 1; }

# ----------- パス設定 -----------
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_DIR="$BASE_DIR/.config"
LINK_MAP_FILE="$CONFIG_DIR/link_map.yaml"

if [[ ! -f $LINK_MAP_FILE ]]; then
  echo "Error: link_map.yaml not found in $CONFIG_DIR" >&2
  exit 1
fi

log "dotfiles: $BASE_DIR"
log "link_map: $LINK_MAP_FILE"
[ "$DRY_RUN" -eq 1 ] && log "=== DRY RUN モード（実際には変更しません）==="
echo ""

CREATED=0
UPDATED=0
SKIPPED=0
WARNINGS=0

# ----------- シンボリックリンク作成関数 -----------
create_symlink() {
  local src="$1"
  local dst="$2"

  local src_full="$BASE_DIR/$src"
  local dst_full="$HOME/$dst"

  # ソースが存在しない場合はスキップ
  if [[ ! -e "$src_full" ]]; then
    warn "ソースが存在しません（スキップ）: $src_full"
    WARNINGS=$((WARNINGS+1))
    return
  fi

  # 宛先ディレクトリを作成
  local dst_dir
  dst_dir=$(dirname "$dst_full")
  if [[ ! -d "$dst_dir" ]]; then
    if [ "$DRY_RUN" -eq 0 ]; then
      mkdir -p "$dst_dir"
    fi
    [ "$VERBOSE" -eq 1 ] && echo "  mkdir: $dst_dir"
  fi

  # 既存リンクの確認
  if [[ -L "$dst_full" ]]; then
    local current_target
    current_target=$(readlink "$dst_full")
    if [[ "$current_target" == "$src_full" ]]; then
      skip "すでにリンク済み: $dst -> $src"
      SKIPPED=$((SKIPPED+1))
      return
    else
      # 別のリンク先に向いている
      if [ "$DRY_RUN" -eq 0 ]; then
        ln -fns "$src_full" "$dst_full"
        ok "更新: $dst -> $src  (旧: $current_target)"
      else
        ok "[DRY] 更新: $dst -> $src  (旧: $current_target)"
      fi
      UPDATED=$((UPDATED+1))
      return
    fi
  elif [[ -e "$dst_full" ]]; then
    warn "既存ファイルを上書きします: ${dst_full}（元ファイルのバックアップは make backup で行ってください）"
    WARNINGS=$((WARNINGS+1))
  fi

  # シンボリックリンクを作成
  if [ "$DRY_RUN" -eq 0 ]; then
    ln -fns "$src_full" "$dst_full"
    ok "作成: $dst -> $src"
  else
    ok "[DRY] 作成: $dst -> $src"
  fi
  CREATED=$((CREATED+1))
}

# ----------- YAML を解析してリンク作成 -----------
apps=$(yq eval 'keys | .[]' "$LINK_MAP_FILE")
for app in $apps; do
  echo "${BOLD}[$app]${RESET}"
  items=$(yq eval ".$app" "$LINK_MAP_FILE")

  if [[ $(yq eval 'type' <<< "$items") == "!!seq" ]]; then
    while IFS= read -r pair; do
      src=$(echo "$pair" | yq eval '.src' -)
      dst=$(echo "$pair" | yq eval '.dst' -)
      create_symlink "$src" "$dst"
    done < <(echo "$items" | yq eval '.[] | @json' -)
  else
    src=$(yq eval '.src' <<< "$items")
    dst=$(yq eval '.dst' <<< "$items")
    create_symlink "$src" "$dst"
  fi
  echo ""
done

# ----------- サマリー -----------
echo "${BOLD}─── 結果 ────────────────────────────────────────${RESET}"
echo "  ${GREEN}✓ 作成${RESET}   $CREATED"
echo "  ${YELLOW}→ 更新${RESET}   $UPDATED"
echo "  - スキップ $SKIPPED"
[ "$WARNINGS" -gt 0 ] && echo "  ${YELLOW}! 警告${RESET}   $WARNINGS" || true
echo ""
[ "$DRY_RUN" -eq 1 ] && echo "${YELLOW}DRY RUN: 実際には何も変更されていません。${RESET}" \
  || echo "${GREEN}${BOLD}セットアップ完了！${RESET}"
