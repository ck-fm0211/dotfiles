# shellcheck disable=SC2148
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# shellcheck disable=SC2296
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  # shellcheck disable=SC1090,SC2296
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# zsh
export HISTFILE="$XDG_STATE_HOME"/zsh/history
# HISTSIZE / SAVEHIST は settings.zsh で一元管理（sheldon 経由で読み込み）

# Homebrew PATH ブートストラップ（sheldon を起動する前に必要）
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# sheldon
command -v sheldon &>/dev/null && eval "$(sheldon source)"

# gcloud
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
# shellcheck disable=SC1091
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# iterm2
# shellcheck disable=SC1091
# shellcheck disable=SC2015
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# shellcheck disable=SC1090
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
