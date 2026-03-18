#!/bin/zsh

# mkcd: ディレクトリ作成して移動
mkcd() {
  mkdir -p "$1" && cd "$1" || return 1
}

# extract: 拡張子に応じてアーカイブを展開
extract() {
  if [ -z "$1" ]; then
    echo "使い方: extract <ファイル>"
    return 1
  fi
  if [ ! -f "$1" ]; then
    echo "Error: '$1' が見つかりません"
    return 1
  fi
  case "$1" in
    *.tar.bz2)  tar xjf "$1"    ;;
    *.tar.gz)   tar xzf "$1"    ;;
    *.tar.xz)   tar xJf "$1"    ;;
    *.tar.zst)  tar --zstd -xf "$1" ;;
    *.tar)      tar xf "$1"     ;;
    *.bz2)      bunzip2 "$1"    ;;
    *.gz)       gunzip "$1"     ;;
    *.zip)      unzip "$1"      ;;
    *.7z)       7z x "$1"       ;;
    *.rar)      unrar x "$1"    ;;
    *.xz)       unxz "$1"       ;;
    *.Z)        uncompress "$1" ;;
    *)          echo "Error: '$1' は未対応の形式です"; return 1 ;;
  esac
}

# up: n 階層上へ移動
up() {
  local count="${1:-1}"
  local path=""
  for _ in $(seq 1 "$count"); do
    path="../$path"
  done
  cd "$path" || return 1
}

# fcd: peco でディレクトリをインタラクティブに選択して移動
fcd() {
  local dir
  dir=$(find "${1:-.}" -type d 2>/dev/null | peco --prompt "cd> ")
  [ -n "$dir" ] && cd "$dir" || return 1
}

# fkill: peco でプロセスを選択して kill
fkill() {
  local pid
  pid=$(ps aux | peco --prompt "kill> " | awk '{print $2}')
  if [ -n "$pid" ]; then
    echo "Killing PID: $pid"
    kill "${1:--TERM}" "$pid"
  fi
}

# gitignore: gitignore.io を使って .gitignore を生成
gitignore() {
  if [ -z "$1" ]; then
    echo "使い方: gitignore <言語/OS> [言語/OS ...]"
    echo "例: gitignore python macos"
    return 1
  fi
  local template
  template=$(printf '%s,' "$@" | sed 's/,$//')
  curl -fsSL "https://www.toptal.com/developers/gitignore/api/${template}"
}

# today: 今日の日付ディレクトリを作成して移動
today() {
  local dir
  dir=$(date +%Y/%m/%d)
  mkcd "$dir"
}

# tre: tree のラッパー（eza を優先）
tre() {
  if command -v eza >/dev/null 2>&1; then
    eza --tree --level="${1:-2}" --group-directories-first
  elif command -v tree >/dev/null 2>&1; then
    tree -L "${1:-2}"
  else
    echo "eza か tree をインストールしてください"
  fi
}

# cdf: Finder の最前面ウィンドウのディレクトリに cd (macOS 限定)
if [[ "$OSTYPE" == darwin* ]]; then
  cdf() {
    local target
    target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
    if [ -n "$target" ]; then
      cd "$target" || return 1
    else
      echo "Finder ウィンドウが開いていません"
      return 1
    fi
  }
fi

# json: JSON を整形して表示（jq 依存）
json() {
  if command -v jq >/dev/null 2>&1; then
    jq '.' "${1:-/dev/stdin}"
  else
    python3 -m json.tool "${1:-/dev/stdin}"
  fi
}

# sman: スクロール可能な man ページ（bat 依存）
if command -v bat >/dev/null 2>&1; then
  sman() {
    man "$@" | bat --style=plain --language=man --paging=always
  }
fi
