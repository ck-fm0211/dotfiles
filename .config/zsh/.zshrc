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

# gcloud（インストール済みの場合のみ読み込む）
# shellcheck disable=SC1091
if command -v gcloud &>/dev/null; then
  GCLOUD_SDK_ROOT="${CLOUDSDK_ROOT_DIR:-$HOME/google-cloud-sdk}"
  if [ -f "$GCLOUD_SDK_ROOT/path.zsh.inc" ]; then . "$GCLOUD_SDK_ROOT/path.zsh.inc"; fi
  # 補完は lazy load（初回 tab 補完時に初期化）
  if [ -f "$GCLOUD_SDK_ROOT/completion.zsh.inc" ]; then
    gcloud_completion_load() {
      # shellcheck disable=SC1091
      . "$GCLOUD_SDK_ROOT/completion.zsh.inc"
      compdef _gcloud gcloud
    }
    compdef gcloud_completion_load gcloud 2>/dev/null || true
  fi
fi

# iterm2
# shellcheck disable=SC1091
# shellcheck disable=SC2015
test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
# shellcheck disable=SC1090
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
