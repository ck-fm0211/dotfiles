# shellcheck disable=SC2148
# .zshrc - 対話シェルのメイン設定ファイル
# 読み込み順: .zshenv → .zshrc（sheldon 経由で各 .zsh を source）

# ----- Powerlevel10k instant prompt（最上部に必須） -----
# shellcheck disable=SC2296
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  # shellcheck disable=SC1090,SC2296
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----- ヒストリファイル（XDG 準拠） -----
# HISTSIZE / SAVEHIST の値は settings.zsh で管理
export HISTFILE="$XDG_STATE_HOME/zsh/history"
# zsh ステートディレクトリが存在しない場合は作成
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
# zsh 補完キャッシュディレクトリを事前に作成
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

# ----- sheldon: プラグインマネージャー -----
# path.zsh → settings.zsh → completion.zsh → alias/functions/bindkey の順で source
eval "$(sheldon source)"

# ----- Google Cloud SDK -----
# shellcheck disable=SC1091
if [[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi
# shellcheck disable=SC1091
if [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# ----- iTerm2 Shell Integration -----
# shellcheck disable=SC1090,SC2015
[[ -f "${ZDOTDIR}/.iterm2_shell_integration.zsh" ]] && \
  source "${ZDOTDIR}/.iterm2_shell_integration.zsh" || true

# ----- Powerlevel10k テーマ -----
# shellcheck disable=SC1090
[[ -f "$XDG_CONFIG_HOME/zsh/.p10k.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/.p10k.zsh"
