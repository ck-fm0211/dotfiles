#!/bin/zsh

## zsh settings
# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
setopt no_beep
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
