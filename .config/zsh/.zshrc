# shellcheck disable=SC2148

# zsh
export HISTFILE="$XDG_STATE_HOME"/zsh/history
# ヒストリに保存するコマンド数
export HISTSIZE=10000
# ヒストリファイルに保存するコマンド数
export SAVEHIST=10000

# sheldon
eval "$(sheldon source)"

# gcloud
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# iterm2
# shellcheck disable=SC1091
# shellcheck disable=SC2015
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true
