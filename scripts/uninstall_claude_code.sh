#!/bin/bash

set -euo pipefail

# XDG変数のフォールバック
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

echo "Claude Codeのインストール状況を確認しています..."

claude_path=$(command -v claude || true)

if [ -z "$claude_path" ]; then
    echo "Claude Codeはインストールされていないか、PATHが通っていません。"
else
    echo "Claude Codeの実行パス: $claude_path"
fi

# 確認メッセージ
read -r -p "Claude Codeをアンインストールしますか？ (y/N): " confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "アンインストールをキャンセルしました。"
    exit 0
fi

echo "Claude Codeのアンインストールを開始します..."

# 1. ネイティブインストールの削除 (XDGのユーザーバイナリディレクトリ)
if [ -f "$HOME/.local/bin/claude" ]; then
    echo "$HOME/.local/bin/claude を削除しています..."
    rm "$HOME/.local/bin/claude"
fi

# 2. npmインストールの削除
if command -v npm >/dev/null 2>&1; then
    echo "npm経由のインストール有無を確認・削除しています..."
    npm uninstall -g @anthropic-ai/claude-code >/dev/null 2>&1 || true
fi

# 3. 設定・キャッシュファイルの削除確認
read -r -p "設定ファイルとキャッシュ（$XDG_CONFIG_HOME/claude 等）も削除しますか？ (y/N): " rm_config
if [[ "$rm_config" =~ ^[yY]$ ]]; then
    echo "設定とキャッシュを削除しています..."

    # XDGに準拠したディレクトリの削除
    rm -rf "$XDG_CONFIG_HOME/claude"
    rm -rf "$XDG_CACHE_HOME/claude"
    rm -rf "$XDG_CACHE_HOME/claude-code"

    # 念のためデフォルトのディレクトリの残骸も削除
    rm -rf "$HOME/.config/claude-code"
    rm -rf "$HOME/.claude"
fi

echo "==========================================="
echo "アンインストールが完了しました。"
echo "※ $XDG_CONFIG_HOME/zsh/.zshenv に追記した export CLAUDE_CONFIG_DIR=... の行は手動で削除してください。"
echo "==========================================="
exit 0
