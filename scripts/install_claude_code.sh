#!/bin/bash

set -e

# 1. XDG変数のフォールバック（未定義の場合はデフォルト値を使用）
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# 2. Claude Code用の環境変数を現在のセッションにエクスポート（インストーラに認識させるため）
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# 3. .zshenv への書き込みを先に済ませる
ZSHENV_PATH="$XDG_CONFIG_HOME/zsh/.zshenv"
# shellcheck disable=SC2016
CLAUDE_CONFIG='export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME"/claude'

echo "環境変数を設定しています..."
if [ -f "$ZSHENV_PATH" ]; then
  if ! grep -q "CLAUDE_CONFIG_DIR" "$ZSHENV_PATH"; then
    # 指摘通り、中括弧で囲ってリダイレクトを1回にまとめる
    {
      echo ""
      echo "# Claude Code"
      echo "$CLAUDE_CONFIG"
    } >> "$ZSHENV_PATH"

    echo "$ZSHENV_PATH に環境変数を追記しました。"
  else
    echo "環境変数はすでに $ZSHENV_PATH に設定されています。"
  fi
else
    echo "$ZSHENV_PATH が見つからなかったため、新しく作成して追記します。"
    mkdir -p "$(dirname "$ZSHENV_PATH")"
    echo "# Claude Code" > "$ZSHENV_PATH"
    echo "$CLAUDE_CONFIG" >> "$ZSHENV_PATH"
fi

# 4. 環境変数が適用された状態でインストーラを実行する
echo "Claude Codeをインストールしています..."
curl -fsSL https://claude.ai/install.sh | bash

echo "==========================================="
echo "Claude Codeのインストールが完了しました。"
echo "ターミナルを再起動するか、以下のコマンドで設定を反映してください:"
echo "source $ZSHENV_PATH"
echo ""
echo "初回起動および認証を行うには、以下のコマンドを実行します:"
echo "claude"
echo "==========================================="
