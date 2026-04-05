#!/bin/zsh
# functions.zsh - カスタム関数定義

# ============================================================
# ディレクトリ操作
# ============================================================

# mkcd: ディレクトリ作成して即移動
mkcd() {
  mkdir -p "$1" && cd "$1" || return 1
}

# up: n 階層上へ移動（例: up 3 → cd ../../..）
up() {
  local count="${1:-1}"
  local path=""
  for _ in $(seq 1 "$count"); do path="../$path"; done
  cd "$path" || return 1
}

# fcd: peco/fzf でディレクトリをインタラクティブに選択して移動
fcd() {
  local dir
  if type "fzf" > /dev/null 2>&1; then
    dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza --tree --level=1 {}' --prompt "cd> ")
  elif type "peco" > /dev/null 2>&1; then
    dir=$(find "${1:-.}" -type d 2>/dev/null | peco --prompt "cd> ")
  else
    echo "peco または fzf が必要です"
    return 1
  fi
  [ -n "$dir" ] && cd "$dir" || return 1
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

# today: 今日の日付ディレクトリ（YYYY/MM/DD）を作成して移動
today() {
  mkcd "$(date +%Y/%m/%d)"
}

# ============================================================
# ファイル操作
# ============================================================

# extract: 拡張子に応じてアーカイブを自動展開
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
    *.tar.bz2)  tar xjf "$1"        ;;
    *.tar.gz)   tar xzf "$1"        ;;
    *.tar.xz)   tar xJf "$1"        ;;
    *.tar.zst)  tar --zstd -xf "$1" ;;
    *.tar)      tar xf "$1"         ;;
    *.bz2)      bunzip2 "$1"        ;;
    *.gz)       gunzip "$1"         ;;
    *.zip)      unzip "$1"          ;;
    *.7z)       7z x "$1"           ;;
    *.rar)      unrar x "$1"        ;;
    *.xz)       unxz "$1"           ;;
    *.Z)        uncompress "$1"     ;;
    *)          echo "Error: '$1' は未対応の形式です"; return 1 ;;
  esac
  echo "展開完了: $1"
}

# tre: ツリー表示（eza を優先）
tre() {
  if type "eza" > /dev/null 2>&1; then
    eza --tree --level="${1:-2}" --group-directories-first
  elif type "tree" > /dev/null 2>&1; then
    tree -L "${1:-2}"
  else
    echo "eza または tree をインストールしてください"
    return 1
  fi
}

# ============================================================
# プロセス・システム
# ============================================================

# fkill: peco/fzf でプロセスを選択して kill
fkill() {
  local signal="${1:--TERM}"
  local pid
  if type "fzf" > /dev/null 2>&1; then
    pid=$(ps aux | fzf --header-lines=1 --prompt "kill ($signal)> " | awk '{print $2}')
  elif type "peco" > /dev/null 2>&1; then
    pid=$(ps aux | peco --prompt "kill ($signal)> " | awk '{print $2}')
  else
    echo "peco または fzf が必要です"
    return 1
  fi
  if [ -n "$pid" ]; then
    echo "Killing PID: $pid"
    kill "$signal" "$pid"
  fi
}

# port: 指定ポートを使用しているプロセスを表示
port() {
  if [ -z "$1" ]; then
    echo "使い方: port <ポート番号>"
    return 1
  fi
  lsof -iTCP:"$1" -sTCP:LISTEN -n -P 2>/dev/null || echo "ポート $1 は使用されていません"
}

# ============================================================
# Git
# ============================================================

# git_cleanup: マージ済みブランチを一括削除
git_cleanup() {
  local main_branch="${1:-main}"
  local merged_branches
  merged_branches=$(git branch --merged "$main_branch" 2>/dev/null | grep -vE "^\*|$main_branch|master|develop" || true)
  if [ -z "$merged_branches" ]; then
    echo "削除対象のブランチはありません"
    return 0
  fi
  echo "以下のブランチを削除します:"
  echo "$merged_branches"
  echo ""
  read -rk1 "reply?続行しますか？ [y/N]: "
  echo ""
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    echo "$merged_branches" | xargs git branch -d
    echo "削除完了"
  else
    echo "キャンセルしました"
  fi
}

# gbr: fzf でブランチをインタラクティブに選択して切り替え
fbr() {
  local branch
  if type "fzf" > /dev/null 2>&1; then
    branch=$(git branch -a --sort=-committerdate 2>/dev/null | \
      fzf --prompt "branch> " --preview 'git log --oneline --graph -20 $(echo {} | sed "s/^\*//" | sed "s|remotes/origin/||")' | \
      sed 's/^\*//' | sed 's|remotes/origin/||' | tr -d ' ')
  elif type "peco" > /dev/null 2>&1; then
    branch=$(git branch -a 2>/dev/null | peco --prompt "branch> " | sed 's/^\*//' | tr -d ' ')
  fi
  [ -n "$branch" ] && git switch "$branch"
}

# ============================================================
# ネットワーク・Web
# ============================================================

# weather: wttr.in から天気予報を取得
weather() {
  local location="${1:-Tokyo}"
  curl -fsSL "https://wttr.in/${location}?lang=ja" 2>/dev/null || echo "天気情報の取得に失敗しました"
}

# serve: カレントディレクトリを HTTP サーバーで公開
serve() {
  local port="${1:-8080}"
  echo "http://localhost:$port を開始します（Ctrl+C で停止）"
  if type "python3" > /dev/null 2>&1; then
    python3 -m http.server "$port"
  elif type "python" > /dev/null 2>&1; then
    python -m SimpleHTTPServer "$port"
  else
    echo "Python が必要です"
    return 1
  fi
}

# ============================================================
# JSON / データ処理
# ============================================================

# json: JSON を整形して表示（jq 依存）
json() {
  if type "jq" > /dev/null 2>&1; then
    jq '.' "${1:-/dev/stdin}"
  else
    python3 -m json.tool "${1:-/dev/stdin}"
  fi
}

# ============================================================
# .gitignore 生成
# ============================================================

# gitignore: gitignore.io を使って .gitignore を生成
gitignore() {
  if [ -z "$1" ]; then
    echo "使い方: gitignore <言語/OS> [...]"
    echo "例: gitignore python macos node"
    echo ""
    echo "利用可能なテンプレート一覧:"
    curl -fsSL "https://www.toptal.com/developers/gitignore/api/list" 2>/dev/null | tr ',' '\n' | sort
    return 0
  fi
  local template
  template=$(printf '%s,' "$@" | sed 's/,$//')
  curl -fsSL "https://www.toptal.com/developers/gitignore/api/${template}"
}

# ============================================================
# ユーティリティ
# ============================================================

# repeat: コマンドを n 回繰り返す（例: repeat 5 echo hello）
repeat() {
  local count="$1"
  shift
  for _ in $(seq 1 "$count"); do
    "$@"
  done
}

# timer: n 秒後に通知（例: timer 60 "コーヒーが出来ました"）
timer() {
  local seconds="${1:-60}"
  local message="${2:-時間です！}"
  echo "${seconds}秒後に通知します: $message"
  sleep "$seconds"
  if [[ "$OSTYPE" == darwin* ]]; then
    local escaped_message
    escaped_message="${message//\"/\\\"}"
    osascript -e "display notification \"${escaped_message}\" with title \"タイマー\"" 2>/dev/null || echo "$message"
  else
    echo "$message"
  fi
}

# sman: bat でシンタックスハイライト付きの man ページを表示
if type "bat" > /dev/null 2>&1; then
  sman() {
    man "$@" | bat --style=plain --language=man --paging=always
  }
fi

# calc: シンプルな計算機（例: calc "1 + 2 * 3"）
calc() {
  python3 -c "import sys; print(eval(sys.argv[1]))" "$*"
}

# goog: デフォルトブラウザで Google 検索
if [[ "$OSTYPE" == darwin* ]]; then
  goog() {
    local query
    query=$(python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))" "$*")
    open "https://www.google.com/search?q=${query}"
  }
fi
