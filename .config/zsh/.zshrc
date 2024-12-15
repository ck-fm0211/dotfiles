# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# add aliases
# ls
if type "eza" > /dev/null 2>&1; then
    alias ls='eza'
    alias l='eza -F'
    alias la='eza -a'
    alias ll='eza -l'
else
    alias ls='ls'
    alias l='ls -CF'
    alias la='ls -A'
    alias ll='ls -l'
fi

# cat
if type "bat" > /dev/null 2>&1; then
    alias cat="bat"
fi

# date
if type "gdate" > /dev/null 2>&1; then
    alias date="gdate"
fi

# date
if type "gsed" > /dev/null 2>&1; then
    alias sed='gsed'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'

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

# Ctrl+rでヒストリ検索
bindkey '^r' anyframe-widget-put-history
# Ctrl+bでブランチ検索
bindkey '^b' anyframe-widget-checkout-git-branch

## zsh settings
# ヒストリファイルを指定
HISTFILE=~/.zsh_history
# ヒストリに保存するコマンド数
HISTSIZE=10000
# ヒストリファイルに保存するコマンド数
SAVEHIST=10000
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

# mise activate
eval "$(/opt/homebrew/bin/mise activate zsh)"

# set theme via `starship`
eval "$(starship init zsh)"

# gcloud
if [ -f '/Users/chikafumi/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/chikafumi/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/chikafumi/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/chikafumi/google-cloud-sdk/completion.zsh.inc'; fi

# iterm2
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true
