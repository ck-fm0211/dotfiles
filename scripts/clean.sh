#!/bin/bash
# clean.sh - 各種キャッシュを削除してディスク容量を解放する
#
# 使い方: make clean
#         make clean DRY_RUN=1  # 削除せずに対象を表示

set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

# ----------- 色付きログ -----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"
  BOLD="$(tput bold)"; RESET="$(tput sgr0)"
else
  GREEN=""; YELLOW=""; BOLD=""; RESET=""
fi

log()     { echo "${BOLD}>>> $*${RESET}"; }
success() { echo "  ${GREEN}✓${RESET} $*"; }
skip()    { echo "  ${YELLOW}-${RESET} $*（スキップ）"; }
dry()     { echo "  ${YELLOW}[DRY]${RESET} $*"; }

# ディスク使用量を GB で取得（クリーン前後の比較用）
disk_used_before() {
  df -g "$HOME" 2>/dev/null | awk 'NR==2 {print $3}' || echo "?"
}

BEFORE=$(disk_used_before)
[ "$DRY_RUN" -eq 1 ] && echo "${YELLOW}${BOLD}=== DRY RUN モード（実際には削除しません）===${RESET}"
echo ""

# ============================================================
# Homebrew
# ============================================================
log "Homebrew キャッシュをクリーンアップしています..."
if command -v brew >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    brew cleanup --prune=all 2>/dev/null || true
    brew autoremove 2>/dev/null || true
    success "Homebrew: brew cleanup --prune=all && brew autoremove"
  else
    brew cleanup --dry-run 2>/dev/null || true
    dry "brew cleanup --prune=all"
  fi
else
  skip "Homebrew が未インストール"
fi

# ============================================================
# Python / pip
# ============================================================
log "Python キャッシュをクリーンアップしています..."
if command -v pip3 >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    pip3 cache purge 2>/dev/null || true
    success "pip: cache purge"
  else
    dry "pip3 cache purge"
  fi
else
  skip "pip3 が未インストール"
fi
# Python __pycache__ を HOME 以下から削除
pycache_count=$(find "$HOME" -maxdepth 8 -name "__pycache__" -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$pycache_count" -gt 0 ]; then
  if [ "$DRY_RUN" -eq 0 ]; then
    find "$HOME" -maxdepth 8 -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    success "Python __pycache__: $pycache_count 件を削除"
  else
    dry "Python __pycache__: $pycache_count 件が対象"
  fi
fi

# ============================================================
# Node.js / npm / yarn
# ============================================================
log "Node.js キャッシュをクリーンアップしています..."
if command -v npm >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    npm cache clean --force 2>/dev/null || true
    success "npm: cache clean"
  else
    dry "npm cache clean --force"
  fi
else
  skip "npm が未インストール"
fi

if command -v yarn >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    yarn cache clean 2>/dev/null || true
    success "yarn: cache clean"
  else
    dry "yarn cache clean"
  fi
else
  skip "yarn が未インストール"
fi

# ============================================================
# Go ビルドキャッシュ
# ============================================================
log "Go キャッシュをクリーンアップしています..."
if command -v go >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    go clean -cache 2>/dev/null || true
    go clean -testcache 2>/dev/null || true
    success "Go: build cache & test cache"
  else
    go_cache_size=$(go env GOCACHE 2>/dev/null | xargs du -sh 2>/dev/null | awk '{print $1}' || echo "?")
    dry "Go build cache ($go_cache_size)"
  fi
else
  skip "Go が未インストール"
fi

# ============================================================
# Docker
# ============================================================
log "Docker キャッシュをクリーンアップしています..."
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    docker system prune -f 2>/dev/null || true
    success "Docker: system prune"
  else
    dry "docker system prune -f"
  fi
else
  skip "Docker が未起動または未インストール"
fi

# ============================================================
# mise キャッシュ
# ============================================================
log "mise キャッシュをクリーンアップしています..."
if command -v mise >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 0 ]; then
    mise cache clear 2>/dev/null || true
    success "mise: cache clear"
  else
    dry "mise cache clear"
  fi
else
  skip "mise が未インストール"
fi

# ============================================================
# Zsh 補完キャッシュ
# ============================================================
log "Zsh 補完キャッシュをクリーンアップしています..."
zsh_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
if [ -d "$zsh_cache" ]; then
  if [ "$DRY_RUN" -eq 0 ]; then
    find "$zsh_cache" -name "zcompdump*" -type f -delete 2>/dev/null || true
    find "$zsh_cache" -name "zcompcache*" -type d -exec rm -rf {} + 2>/dev/null || true
    success "Zsh: 補完キャッシュを削除（${zsh_cache}）"
  else
    dry "Zsh: $zsh_cache の zcompdump/zcompcache を削除"
  fi
fi

# ============================================================
# macOS システムキャッシュ
# ============================================================
log "macOS システムキャッシュをクリーンアップしています..."
if [[ "$(uname -s)" == "Darwin" ]]; then
  if [ "$DRY_RUN" -eq 0 ]; then
    # ユーザーキャッシュ（Library/Caches）のサイズの大きいものを削除
    find "$HOME/Library/Caches" -maxdepth 1 -type d 2>/dev/null | while read -r d; do
      size=$(du -sm "$d" 2>/dev/null | awk '{print $1}' || echo "0")
      if [ "${size:-0}" -gt 500 ]; then
        rm -rf "$d" && echo "  ${GREEN}✓${RESET} 削除: $d (${size}MB)"
      fi
    done
    success "macOS: Library/Caches の 500MB 超えエントリを削除"
  else
    total=$(du -sh "$HOME/Library/Caches" 2>/dev/null | awk '{print $1}' || echo "?")
    dry "macOS: Library/Caches ($total)"
  fi
fi

# ============================================================
# 結果サマリ
# ============================================================
echo ""
echo "${BOLD}─── クリーンアップ完了 ──────────────────────────────${RESET}"
if [ "$DRY_RUN" -eq 0 ]; then
  AFTER=$(disk_used_before)
  echo "  クリーン前: ${BEFORE}GB 使用"
  echo "  クリーン後: ${AFTER}GB 使用"
else
  echo "  ${YELLOW}DRY RUN: 実際には何も削除されていません${RESET}"
  echo "  実際に削除するには: make clean"
fi
