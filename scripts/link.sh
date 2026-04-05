#!/bin/bash

# 必要なコマンドの存在を確認
define_error_exit() {
  echo "Error: $1 is not installed. Please install it first." >&2
  exit 1
}

command -v yq >/dev/null 2>&1 || define_error_exit "yq"

# カレントディレクトリの設定
BASE_DIR=$(cd $(dirname "$0") && cd .. && pwd)
CONFIG_DIR="$BASE_DIR/.config"
LINK_MAP_FILE="$CONFIG_DIR/link_map.yaml"

# link_map.yamlの存在確認
if [[ ! -f $LINK_MAP_FILE ]]; then
  echo "Error: link_map.yaml not found in $CONFIG_DIR" >&2
  exit 1
fi

echo "link_map.yaml: $CONFIG_DIR/link_map.yaml"

# シンボリックリンク作成関数
create_symlink() {
  local src=$1
  local dst=$2

  src_full_path="$BASE_DIR/$src"
  dst_full_path="$HOME/$dst"

  # ソースファイルが存在しない場合、警告を出してスキップ
  if [[ ! -e $src_full_path ]]; then
    echo -e "Warning: Source file $src_full_path does not exist. Skipping.\n" >&2
    return
  fi

  # シンボリックリンクを張る先のディレクトリを作成
  dst_dir=$(dirname "$dst_full_path")
  if [[ ! -d $dst_dir ]]; then
    echo "Creating directory: $dst_dir"
    mkdir -p "$dst_dir"
  fi

  # シンボリックリンクを作成
  ln -fnsv "$src_full_path" "$dst_full_path"
  echo ""
}

# YAMLを解析してシンボリックリンクを作成
apps=$(yq eval 'keys | .[]' "$LINK_MAP_FILE")
for app in $apps; do
  items=$(yq eval ".$app" "$LINK_MAP_FILE")

  if [[ $(yq eval 'type' <<< "$items") == "!!seq" ]]; then
    # 配列の場合
    for pair in $(echo "$items" | yq eval '.[] | @json' -); do
      src=$(echo "$pair" | yq eval '.src' -)
      dst=$(echo "$pair" | yq eval '.dst' -)
      create_symlink "$src" "$dst"
    done
  else
    # オブジェクトの場合
    src=$(yq eval '.src' <<< "$items")
    dst=$(yq eval '.dst' <<< "$items")
    create_symlink "$src" "$dst"
  fi

done

echo "Dotfiles setup completed successfully."
