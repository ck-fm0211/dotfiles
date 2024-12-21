# shellcheck disable=SC2148

# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
setopt no_beep

# sheldon
eval "$(sheldon source)"

## コマンド補完
autoload -Uz compinit && compinit

## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 補完候補を一覧表示したとき、Tabや矢印で選択できるようにする
zstyle ':completion:*:default' menu select=1 

## zcompcacheの場所を変更
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache

## .zcompdumpの場所を変更
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# Ctrl+rでヒストリ検索
bindkey '^r' anyframe-widget-put-history
# Ctrl+bでブランチ検索
bindkey '^b' anyframe-widget-checkout-git-branch

## zsh settings
# 重複するコマンド行は古い方を削除
setopt hist_ignore_all_dups
# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups
# 履歴を追加 (毎回 .zsh_history を作るのではなく)
setopt append_history
# 履歴をインクリメンタルに追加
setopt inc_append_history
# 余分な空白は詰めて記録
setopt hist_reduce_blanks
# 補完時にヒストリを自動的に展開
setopt hist_expand
# 同時に起動したzshの間でヒストリを共有する
setopt share_history
