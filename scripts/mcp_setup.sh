#!/bin/bash

set -euo pipefail

# XDG_CONFIG_HOME のフォールバック（未定義の場合はデフォルト値を使用）
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# MCP サーバー定義ファイルのパス
MCP_SERVERS_JSON="$XDG_CONFIG_HOME/claude/mcp-servers.json"
SYNC_MODE=0

usage() {
  cat <<'EOF'
Usage: mcp_setup.sh [--sync]

  --sync    mcp-servers.json に存在しない登録済みサーバーも削除して同期する
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --sync)
      SYNC_MODE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "エラー: 未知のオプションです: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

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

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

desired_names_file="$tmp_dir/desired_names.txt"
registered_names_file="$tmp_dir/registered_names.txt"

# JSON の各エントリに対して処理（bash 3.2 互換: mapfile の代わりに while read を使用）
server_names=()
while IFS= read -r line; do
  server_names+=("$line")
done < <(jq -r 'keys[]' "$MCP_SERVERS_JSON")

printf '%s\n' "${server_names[@]}" > "$desired_names_file"

while IFS= read -r line; do
  [ -z "$line" ] && continue
  name_only="$(printf '%s\n' "$line" | awk '{print $1}')"
  [ -n "$name_only" ] && printf '%s\n' "$name_only" >> "$registered_names_file"
done < <(claude mcp list 2>/dev/null | tail -n +2)

if [ "$SYNC_MODE" -eq 1 ] && [ -f "$registered_names_file" ]; then
  while IFS= read -r name; do
    [ -z "$name" ] && continue

    if ! grep -Fqx -- "$name" "$desired_names_file"; then
      echo "削除: ${name} は mcp-servers.json に存在しないため登録を解除します。"
      claude mcp remove -s user "$name"
    fi
  done < "$registered_names_file"
fi

for name in "${server_names[@]}"; do
  # 既登録チェック: 機械可読な get コマンドの終了コードで判定
  if claude mcp get "$name" > /dev/null 2>&1; then
    echo "スキップ: ${name} はすでに登録済みです。"
    continue
  fi

  # type フィールドを取得
  server_type="$(jq -r --arg n "$name" '.[$n].type' "$MCP_SERVERS_JSON")"

  if [ "$server_type" = "stdio" ]; then
    # コマンドと引数を取得
    server_command="$(jq -r --arg n "$name" '.[$n].command' "$MCP_SERVERS_JSON")"
    args_count="$(jq -r --arg n "$name" '(.[$n].args // []) | length' "$MCP_SERVERS_JSON")"

    # -e KEY=VALUE 形式の環境変数フラグを構築
    env_flags=()
    env_count="$(jq -r --arg n "$name" '(.[$n].env // {}) | length' "$MCP_SERVERS_JSON")"
    if [ "$env_count" -gt 0 ]; then
      # 環境変数を KEY=VALUE 形式で列挙して -e フラグを付与
      while IFS="=" read -r key value; do
        env_flags+=("-e" "${key}=${value}")
      done < <(jq -r --arg n "$name" '(.[$n].env // {}) | to_entries[] | "\(.key)=\(.value)"' "$MCP_SERVERS_JSON")
    fi

    # args が空の場合はコマンドだけ、ある場合は引数を展開して渡す
    if [ "$args_count" -eq 0 ]; then
      claude mcp add -s user "$name" -t stdio "${env_flags[@]}" -- "$server_command"
    else
      # args 配列を改行区切りで読み取り、配列に格納（bash 3.2 互換）
      server_args=()
      while IFS= read -r line; do
        server_args+=("$line")
      done < <(jq -r --arg n "$name" '(.[$n].args // [])[]' "$MCP_SERVERS_JSON")
      claude mcp add -s user "$name" -t stdio "${env_flags[@]}" -- "$server_command" "${server_args[@]}"
    fi

    echo "登録完了: ${name} (stdio)"

  else
    echo "警告: ${name} の type \"${server_type}\" は未対応です。スキップします。" >&2
  fi
done

echo "MCP サーバーの登録が完了しました。"
