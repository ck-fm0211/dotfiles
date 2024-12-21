#!/bin/zsh

## .zcompdumpの場所を変更
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
## 補完候補を一覧表示したとき、Tabや矢印で選択できるようにする
zstyle ':completion:*:default' menu select=1 
## zcompcacheの場所を変更
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
