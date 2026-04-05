#!/bin/bash

set -e

# XDG_CONFIG_HOME のフォールバック（未定義の場合はデフォルト値を使用）
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# MCP サーバー定義ファイルのパス
MCP_SERVERS_JSON="$XDG_CONFIG_HOME/claude/mcp-servers.json"

# jq コマンドの存在確認
if ! command -v jq > /dev/null 2>&1; then
  echo "エラー: jq が見つかりません。brew install jq で導入してください。" >&2
  exit 1
fi

# claude コマンドの存在確認
if ! command -v claude > /dev/null 2>&1; then
  echo "エラー: claude コマンドが見つかりません。install-claude-code を先に実行してください。" >&2
  exit 1
fi

# MCP サーバー定義ファイルの存在確認
if [ ! -f "$MCP_SERVERS_JSON" ]; then
  echo "エラー: $MCP_SERVERS_JSON が見つかりません。" >&2
  exit 1
fi

echo "MCP サーバーを登録しています..."

# 現在登録済みの MCP サーバー名を取得
registered_servers="$(claude mcp list 2>/dev/null || true)"

# JSON の各エントリに対して処理
server_names="$(jq -r 'keys[]' "$MCP_SERVERS_JSON")"

for name in $server_names; do
  # 既登録チェック: サーバー名が一覧に含まれているか確認
  if echo "$registered_servers" | grep -q "^${name}"; then
    echo "スキップ: ${name} はすでに登録済みです。"
    continue
  fi

  # type フィールドを取得
  server_type="$(jq -r --arg n "$name" '.[$n].type' "$MCP_SERVERS_JSON")"

  if [ "$server_type" = "stdio" ]; then
    # コマンドと引数を取得
    server_command="$(jq -r --arg n "$name" '.[$n].command' "$MCP_SERVERS_JSON")"
    args_count="$(jq -r --arg n "$name" '.[$n].args | length' "$MCP_SERVERS_JSON")"

    # -e KEY=VALUE 形式の環境変数フラグを構築
    env_flags=""
    env_count="$(jq -r --arg n "$name" '.[$n].env | length' "$MCP_SERVERS_JSON")"
    if [ "$env_count" -gt 0 ]; then
      # 環境変数を KEY=VALUE 形式で列挙して -e フラグを付与
      while IFS="=" read -r key value; do
        env_flags="${env_flags} -e ${key}=${value}"
      done < <(jq -r --arg n "$name" '.[$n].env | to_entries[] | "\(.key)=\(.value)"' "$MCP_SERVERS_JSON")
    fi

    # args が空の場合はコマンドだけ、ある場合は引数を展開して渡す
    if [ "$args_count" -eq 0 ]; then
      if [ -n "$env_flags" ]; then
        # shellcheck disable=SC2086
        claude mcp add -s user "$name" -t stdio $env_flags -- "$server_command"
      else
        claude mcp add -s user "$name" -t stdio -- "$server_command"
      fi
    else
      # args 配列を改行区切りで読み取り、配列に格納
      mapfile -t server_args < <(jq -r --arg n "$name" '.[$n].args[]' "$MCP_SERVERS_JSON")
      if [ -n "$env_flags" ]; then
        # shellcheck disable=SC2086
        claude mcp add -s user "$name" -t stdio $env_flags -- "$server_command" "${server_args[@]}"
      else
        claude mcp add -s user "$name" -t stdio -- "$server_command" "${server_args[@]}"
      fi
    fi

    echo "登録完了: ${name} (stdio)"

  else
    echo "警告: ${name} の type \"${server_type}\" は未対応です。スキップします。" >&2
  fi
done

echo "MCP サーバーの登録が完了しました。"
