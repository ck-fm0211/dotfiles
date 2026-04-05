# shellcheck disable=SC2148
# .zshenv - 対話・非対話の両シェルで読み込まれる環境変数
# ここにはパス非依存の純粋な環境変数のみ定義する
# PATH 管理は .config/zsh/path.zsh で行う

# ----- XDG Base Directory -----
# https://wiki.archlinux.jp/index.php/XDG_Base_Directory
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# ----- Homebrew -----
export HOMEBREW_BUNDLE_FILE_GLOBAL="$XDG_CONFIG_HOME/homebrew/Brewfile"
# インストール時の解析を無効化（プライバシー）
export HOMEBREW_NO_ANALYTICS=1
# Homebrew の自動更新を手動管理
export HOMEBREW_NO_AUTO_UPDATE=1

# ----- AWS CLI -----
export AWS_PAGER=""

# ----- Docker -----
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# ----- less -----
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export LESS="-R --use-color"

# ----- Python -----
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"

# ----- bat (cat 代替) -----
export BAT_THEME="Solarized (dark)"

# ----- ターミナル・ロケール -----
export CLICOLOR=1
export LANG=ja_JP.UTF-8
export LSCOLORS=gxfxcxdxbxegedabagacad

# ----- Claude Code -----
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# ----- その他ツール（XDG 準拠） -----
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/config"
