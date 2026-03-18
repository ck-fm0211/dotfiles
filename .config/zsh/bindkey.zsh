#!/bin/zsh

# Emacs 風キーバインドをベースにする
bindkey -e

# ----- anyframe（ファジーファインダー連携）-----
# Ctrl+r: ヒストリ検索
bindkey '^r' anyframe-widget-put-history
# Ctrl+b: Git ブランチをチェックアウト
bindkey '^b' anyframe-widget-checkout-git-branch

# ----- 単語移動 -----
# Option+← / Option+→ で単語単位移動（macOS iTerm2）
bindkey '^[b' backward-word
bindkey '^[f' forward-word
# Ctrl+← / Ctrl+→
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# ----- 行編集 -----
# Ctrl+a: 行頭へ移動
bindkey '^a' beginning-of-line
# Ctrl+e: 行末へ移動
bindkey '^e' end-of-line
# Ctrl+k: カーソル以降を削除
bindkey '^k' kill-line
# Ctrl+u: 行全体を削除
bindkey '^u' kill-whole-line
# Ctrl+w: 単語を後方削除
bindkey '^w' backward-kill-word

# ----- ヒストリ検索 -----
# 上下矢印でプレフィックス一致ヒストリ検索
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
# Ctrl+p / Ctrl+n でも同様に
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward

# ----- 補完 -----
# Tab で候補選択開始（menu-complete）
bindkey '^i' menu-complete
# Shift+Tab で逆方向に候補移動
bindkey '^[[Z' reverse-menu-complete
