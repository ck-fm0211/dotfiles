#!/bin/bash

set -e

# XDG_CONFIG_HOME のフォールバック（未定義の場合はデフォルト値を使用）
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Claude Code の設定ファイルパス
CLAUDE_JSON="${CLAUDE_CONFIG_DIR:-$XDG_CONFIG_HOME/claude}/.claude.json"
MCP_SERVERS_JSON="$XDG_CONFIG_HOME/claude/mcp-servers.json"

# jq コマンドの存在確認
if ! command -v jq > /dev/null 2>&1; then
  echo "エラー: jq が見つかりません。brew install jq で導入してください。" >&2
  exit 1
fi

# .claude.json の存在確認
if [ ! -f "$CLAUDE_JSON" ]; then
  echo "エラー: $CLAUDE_JSON が見つかりません。Claude Code を起動したことがあるか確認してください。" >&2
  exit 1
fi

# mcpServers フィールドを抽出して mcp-servers.json に書き出す
echo "MCP サーバー設定をエクスポートしています..."
echo "  ソース : $CLAUDE_JSON"
echo "  出力先 : $MCP_SERVERS_JSON"

jq '.mcpServers // {}' "$CLAUDE_JSON" > "$MCP_SERVERS_JSON"

echo "エクスポートが完了しました。"
echo "登録済み MCP サーバー:"
jq -r 'keys[]' "$MCP_SERVERS_JSON" | sed 's/^/  - /'
