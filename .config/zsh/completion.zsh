#!/bin/zsh
# completion.zsh - Zsh 補完の設定

# zcompdump の場所を XDG に準拠
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# zcompcache の場所を変更
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache

# ----- マッチング設定 -----
# 小文字で大文字にもマッチ
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=* l:|=*'

# ----- 見た目 -----
# Tab で候補一覧を表示し、矢印キーで選択できる
zstyle ':completion:*:default' menu select=1

# 補完候補をグループ分けして表示
zstyle ':completion:*' group-name ''

# グループ名を太字で表示
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages'     format '%d'
zstyle ':completion:*:warnings'     format '補完候補がありません: %d'
zstyle ':completion:*:corrections'  format '%B%d (errors: %e)%b'

# ls のカラー設定を補完にも適用
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ----- 特定コマンドの補完挙動 -----
# kill コマンド: プロセス名でも補完
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# cd: ドットファイルも補完対象
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# rm / cp / mv: 関連ファイルを先に表示
zstyle ':completion:*:(rm|cp|mv):*' ignore-line other

# ssh: 既知のホストを補完
zstyle ':completion:*:ssh:*' hosts off

# Git: verbose な補完
zstyle ':completion:*:git-checkout:*' sort false

# ----- パフォーマンス -----
# 補完キャッシュを有効化
zstyle ':completion:*' use-cache yes
# 補完候補の数が多いときに一覧表示
zstyle ':completion:*' list-prompt '%STab キーで続きを表示 (%p)%s'
