#!/bin/zsh
# alias.zsh - コマンドエイリアス定義

# ============================================================
# ls / eza
# ============================================================
if type "eza" > /dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias l='eza -F --group-directories-first'
  alias la='eza -a --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias lla='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
  alias lta='eza --tree --level=2 --group-directories-first -a'
else
  alias ls='ls'
  alias l='ls -CF'
  alias la='ls -A'
  alias ll='ls -lh'
  alias lla='ls -lAh'
fi

# ============================================================
# cat / bat
# ============================================================
if type "bat" > /dev/null 2>&1; then
  alias cat="bat --style=plain"
  alias bcat="bat"                         # bat フル機能版
fi

# ============================================================
# grep / ripgrep
# ============================================================
if type "rg" > /dev/null 2>&1; then
  alias grep='rg'
fi

# ============================================================
# find / fd
# ============================================================
if type "fd" > /dev/null 2>&1; then
  alias find='fd'
fi

# ============================================================
# GNU ツール（macOS の BSD 版を上書き）
# ============================================================
type "gdate" > /dev/null 2>&1 && alias date="gdate"
type "gsed"  > /dev/null 2>&1 && alias sed='gsed'
type "gawk"  > /dev/null 2>&1 && alias awk='gawk'

# ============================================================
# diff
# ============================================================
type "colordiff" > /dev/null 2>&1 && alias diff='colordiff'

# ============================================================
# 安全操作（確認プロンプト付き）
# ============================================================
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ============================================================
# エディタ
# ============================================================
alias vi='vim'
if type "code" > /dev/null 2>&1; then
  alias e='code'      # VSCode でファイルを開く
  alias c='code .'    # カレントディレクトリを VSCode で開く
fi

# ============================================================
# ディレクトリ移動
# ============================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# ============================================================
# Git
# ============================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gsw='git switch'
alias gbr='git branch'
alias gst='git stash'
alias gstp='git stash pop'

# ============================================================
# GitHub CLI
# ============================================================
if type "gh" > /dev/null 2>&1; then
  alias ghpr='gh pr create'           # PR を作成
  alias ghprl='gh pr list'            # PR 一覧
  alias ghprv='gh pr view --web'      # PR をブラウザで開く
  alias ghprc='gh pr checkout'        # PR をチェックアウト
  alias ghis='gh issue list'          # Issue 一覧
  alias ghrun='gh run list'           # CI/CD 実行一覧
  alias ghw='gh run watch'            # CI/CD を監視
  alias ghbr='gh browse'              # リポジトリをブラウザで開く
fi

# ============================================================
# mise
# ============================================================
if type "mise" > /dev/null 2>&1; then
  alias mi='mise install'             # ツールをインストール
  alias mu='mise upgrade'             # アップグレード
  alias ml='mise list'                # インストール済み一覧
  alias mls='mise ls-remote'          # インストール可能バージョン一覧
  alias mc='mise current'             # 現在のバージョン
fi

# ============================================================
# Docker
# ============================================================
if type "docker" > /dev/null 2>&1; then
  alias dk='docker'
  alias dkc='docker compose'
  alias dkps='docker ps'
  alias dkpsa='docker ps -a'
  alias dki='docker images'
  alias dkrm='docker rm'
  alias dkrmi='docker rmi'
  alias dkex='docker exec -it'        # インタラクティブに接続
  alias dklog='docker logs -f'        # ログをフォロー
  alias dkclean='docker system prune -f' # 不要リソースを削除
fi

# ============================================================
# ネットワーク
# ============================================================
alias myip='curl -s https://checkip.amazonaws.com'
alias localip="ipconfig getifaddr en0 2>/dev/null || ip addr show | grep 'inet ' | awk '{print \$2}'"
alias ports='lsof -iTCP -sTCP:LISTEN -n -P'   # 開放ポート一覧
alias pingg='ping -c 5 8.8.8.8'               # Google DNS に ping

# ============================================================
# macOS 向け
# ============================================================
if [[ "$OSTYPE" == darwin* ]]; then
  alias finder='open .'                        # Finder でカレントを開く
  alias clip='pbcopy'                          # クリップボードにコピー
  alias paste='pbpaste'                        # クリップボードからペースト
  alias showfiles='defaults write com.apple.finder AppleShowAllFiles true  && killall Finder'
  alias hidefiles='defaults write com.apple.finder AppleShowAllFiles false && killall Finder'
  alias cleanup='find . -name ".DS_Store" -type f -delete && echo "Done"'
  alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo "DNS flushed"'
  alias sleepnow='pmset sleepnow'              # 即座にスリープ
fi

# ============================================================
# Make
# ============================================================
alias mk='make'
alias mh='make help'

# ============================================================
# よく使うコマンドの短縮
# ============================================================
alias h='history'
alias path='echo $PATH | tr ":" "\n" | nl'    # PATH を見やすく表示（行番号付き）
alias reload='exec $SHELL -l'                   # シェルをリロード
alias week='date +%V'                           # 現在の週番号

# ============================================================
# JSON / YAML
# ============================================================
type "jq" > /dev/null 2>&1 && alias jqp='jq .'    # JSON を整形
type "yq" > /dev/null 2>&1 && alias yqp='yq eval . -P' # YAML を整形
