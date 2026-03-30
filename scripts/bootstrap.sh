#!/bin/bash
# bootstrap.sh - 新規 Mac を一発でセットアップ
#
# 使い方（リポジトリなしの状態から）:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ck-fm0211/dotfiles/main/scripts/bootstrap.sh)"
#
# または、リポジトリ clone 後:
#   ./scripts/bootstrap.sh

set -euo pipefail

DOTFILES_REPO="https://github.com/ck-fm0211/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"

# ----------- 色付きログ -----------
log()     { printf '\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
success() { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn()    { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
error()   { printf '\033[1;31m  ✗\033[0m %s\n' "$*" >&2; }
die()     { error "$*"; exit 1; }

# ----------- macOS バージョン確認 -----------
log "macOS バージョンを確認しています..."
macos_version=$(sw_vers -productVersion)
macos_major=$(echo "$macos_version" | cut -d. -f1)
if [ "$macos_major" -lt 13 ]; then
  warn "macOS $macos_version を検出しました。macOS 13 (Ventura) 以上を推奨します。"
else
  success "macOS $macos_version"
fi

# ----------- Xcode Command Line Tools -----------
log "Xcode Command Line Tools を確認しています..."
if ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode Command Line Tools をインストールします（ダイアログが表示される場合があります）..."
  xcode-select --install
  # インストール完了を待つ
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
  success "Xcode Command Line Tools をインストールしました"
else
  success "Xcode Command Line Tools: $(xcode-select -p)"
fi

# ----------- dotfiles の取得 -----------
log "dotfiles を取得しています..."
if [ -d "$DOTFILES_DIR/.git" ]; then
  warn "既存の dotfiles ディレクトリが見つかりました: $DOTFILES_DIR"
  warn "git pull で最新化します..."
  git -C "$DOTFILES_DIR" pull --rebase origin main
  success "dotfiles を最新化しました"
elif [ -d "$DOTFILES_DIR" ]; then
  die "$DOTFILES_DIR は存在しますが git リポジトリではありません。手動で確認してください。"
else
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  success "dotfiles を clone しました: $DOTFILES_DIR"
fi

# ----------- セットアップ実行 -----------
log "セットアップを開始します..."
cd "$DOTFILES_DIR"

make install
make link
make brew-bundle-taps
make brew-bundle
make brew-bundle-cask
make brew-bundle-vscode
make sheldon

log "macOS システム設定を適用しています..."
make mac-defaults

log "クラウドツールをインストールしています..."
make install-awscli  || warn "AWS CLI のインストールに失敗しました（スキップ）"
make install-gcloud  || warn "Google Cloud SDK のインストールに失敗しました（スキップ）"
make install-claude-code || warn "Claude Code のインストールに失敗しました（スキップ）"

# ----------- 完了 -----------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
success "セットアップが完了しました！"
echo ""
echo "  次のステップ:"
echo "  1. OS を再起動してください: sudo shutdown -r now"
echo "  2. 再起動後、ターミナルを開いて認証を行ってください:"
echo "     aws configure"
echo "     gcloud init"
echo "     claude"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
