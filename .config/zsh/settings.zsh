#!/bin/zsh

## zsh settings

# ----- ヒストリ設定 -----
# ヒストリに保存するコマンド数
export HISTSIZE=100000
# ヒストリファイルに保存するコマンド数
export SAVEHIST=100000
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
# ヒストリにコマンド実行時刻を記録
setopt extended_history

# ----- 入力・編集 -----
# コマンドのスペルを訂正
setopt correct
# '#'以降をコメントとして扱う
setopt interactive_comments
# = の後をファイル名展開する
setopt magic_equal_subst
# カーソル位置のコマンドを補完する
setopt complete_in_word
# 補完後、末尾スラッシュを残す
setopt no_auto_remove_slash

# ----- 表示・UI -----
# ビープ音を鳴らさない
setopt no_beep
# ファイルグロブが一致しなくてもエラーにしない
setopt no_nomatch
# ディレクトリ名だけで cd する
setopt auto_cd
# cd 時に自動的にディレクトリスタックに追加
setopt auto_pushd
# 同じディレクトリはスタックに追加しない
setopt pushd_ignore_dups
