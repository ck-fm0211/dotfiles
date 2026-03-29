#!/bin/bash
# doctor.sh - dotfiles 環境の包括的な健全性チェック
#
# 使い方: make doctor  または  ./scripts/doctor.sh

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LINK_MAP="$BASE_DIR/.config/link_map.yaml"

# ----------- 色の設定 -----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  GREEN="$(tput setaf 2)"; RED="$(tput setaf 1)"
  YELLOW="$(tput setaf 3)"; CYAN="$(tput setaf 6)"
  BOLD="$(tput bold)"; RESET="$(tput sgr0)"
else
  GREEN=""; RED=""; YELLOW=""; CYAN=""; BOLD=""; RESET=""
fi

PASS=0; FAIL=0; WARN=0

ok()      { echo "  ${GREEN}✓${RESET} $*"; PASS=$((PASS+1)); }
fail()    { echo "  ${RED}✗${RESET} $*"; FAIL=$((FAIL+1)); }
warn()    { echo "  ${YELLOW}!${RESET} $*"; WARN=$((WARN+1)); }
info()    { echo "  ${CYAN}i${RESET} $*"; }
section() {
  echo
  echo "${BOLD}${CYAN}■ $*${RESET}"
  printf "${CYAN}%0.s─${RESET}" $(seq 1 50)
  echo
}

# ----------- macOS・システム情報 -----------
section "システム情報"
if [[ "$(uname -s)" == "Darwin" ]]; then
  macos_version=$(sw_vers -productVersion)
  macos_major=$(echo "$macos_version" | cut -d. -f1)
  if [ "$macos_major" -ge 13 ]; then
    ok "macOS $macos_version"
  elif [ "$macos_major" -ge 12 ]; then
    warn "macOS ${macos_version}（Monterey は非推奨。Ventura 以上を推奨）"
  else
    fail "macOS ${macos_version}（サポート対象外。Ventura 以上が必要）"
  fi
  arch_type=$(uname -m)
  case "$arch_type" in
    arm64)  ok "CPU: Apple Silicon (arm64)" ;;
    x86_64) ok "CPU: Intel (x86_64)" ;;
    *)      warn "CPU: 不明 ($arch_type)" ;;
  esac
else
  warn "非 macOS 環境（$(uname -s)）。一部のチェックをスキップします。"
fi

# ディスク空き容量
if command -v df >/dev/null 2>&1; then
  available_gb=$(df -g "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
  if [ "${available_gb:-0}" -ge 20 ]; then
    ok "ディスク空き容量: ${available_gb}GB"
  elif [ "${available_gb:-0}" -ge 10 ]; then
    warn "ディスク空き容量が少なめです: ${available_gb}GB（20GB 以上推奨、make clean で整理できます）"
  else
    fail "ディスク空き容量が危険域です: ${available_gb}GB（make clean を今すぐ実行してください）"
  fi
fi

# ----------- XDG Base Directory -----------
section "XDG Base Directories"
for dir in \
  "$HOME/.config" \
  "$HOME/.cache" \
  "$HOME/.local/share" \
  "$HOME/.local/state" \
  "$HOME/.cache/zsh" \
  "$HOME/.local/state/zsh" \
  "$HOME/.local/state/less" \
  "$HOME/.local/state/python"; do
  if [ -d "$dir" ]; then
    ok "$dir"
  else
    fail "${dir}（make install で作成されます）"
  fi
done

if grep -q "ZDOTDIR" /etc/zshenv 2>/dev/null; then
  zdotdir_val=$(grep "ZDOTDIR" /etc/zshenv | head -1 | xargs)
  ok "/etc/zshenv: $zdotdir_val"
else
  fail "/etc/zshenv に ZDOTDIR が未設定（make install を実行してください）"
fi

# ----------- 必須コマンド -----------
section "必須コマンド"
for entry in \
  "brew:Homebrew パッケージマネージャー" \
  "git:バージョン管理" \
  "zsh:シェル" \
  "yq:YAML パーサー (make install)" \
  "sheldon:Zsh プラグインマネージャー (brew install sheldon)" \
  "mise:ランタイムバージョンマネージャー (brew install mise)"; do
  cmd="${entry%%:*}"
  desc="${entry#*:}"
  if command -v "$cmd" >/dev/null 2>&1; then
    version=$("$cmd" --version 2>/dev/null | head -1 || echo "")
    ok "$cmd${version:+ — $version}"
  else
    fail "$cmd が未インストール（${desc}）"
  fi
done

# ----------- 推奨コマンド -----------
section "推奨コマンド"
for entry in \
  "bat:cat の代替 (brew install bat)" \
  "eza:ls の代替 (brew install eza)" \
  "fd:find の代替 (brew install fd)" \
  "rg:grep の代替 ripgrep (brew install ripgrep)" \
  "fzf:ファジーファインダー (brew install fzf)" \
  "gh:GitHub CLI (brew install gh)" \
  "jq:JSON パーサー (brew install jq)" \
  "peco:インタラクティブフィルター (brew install peco)" \
  "colordiff:カラー diff (brew install colordiff)" \
  "shellcheck:シェルスクリプト解析 (brew install shellcheck)" \
  "tldr:man ページ簡易版 (brew install tldr)" \
  "gdate:GNU date (brew install coreutils)" \
  "gsed:GNU sed (brew install gnu-sed)" \
  "htop:プロセスビューア (brew install htop)" \
  "wget:ファイルダウンロード (brew install wget)"; do
  cmd="${entry%%:*}"
  desc="${entry#*:}"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd"
  else
    warn "$cmd が未インストール（${desc}）"
  fi
done

# ----------- クラウドツール -----------
section "クラウドツール"
for entry in \
  "aws:AWS CLI:make install-awscli" \
  "gcloud:Google Cloud SDK:make install-gcloud" \
  "claude:Claude Code:make install-claude-code"; do
  cmd="${entry%%:*}"; rest="${entry#*:}"
  desc="${rest%%:*}"; install_cmd="${rest#*:}"
  if command -v "$cmd" >/dev/null 2>&1; then
    version=$("$cmd" --version 2>/dev/null | head -1 || echo "")
    ok "$cmd${version:+ — $version}"
  else
    warn "${desc}が未インストール（${install_cmd}）"
  fi
done

# ----------- Git 設定 -----------
section "Git 設定"
git_name=$(git config --global user.name 2>/dev/null || echo "")
git_email=$(git config --global user.email 2>/dev/null || echo "")
git_branch=$(git config --global init.defaultBranch 2>/dev/null || echo "")
git_hooks=$(git config --global core.hooksPath 2>/dev/null || echo "")

if [ -n "$git_name" ]; then
  ok "user.name: $git_name"
else
  fail "git user.name が未設定（git config --global user.name '名前'）"
fi
if [ -n "$git_email" ]; then
  ok "user.email: $git_email"
else
  fail "git user.email が未設定（git config --global user.email 'email@example.com'）"
fi
if [ "$git_branch" = "main" ]; then
  ok "init.defaultBranch: main"
else
  warn "init.defaultBranch: ${git_branch:-未設定}（'main' を推奨）"
fi
if [ -n "$git_hooks" ]; then
  if [ -d "$git_hooks" ]; then
    hook_count=$(find "$git_hooks" -maxdepth 1 -type f -perm +111 2>/dev/null | wc -l | tr -d ' ')
    ok "core.hooksPath: ${git_hooks}（${hook_count}件の実行可能フック）"
  else
    warn "core.hooksPath が設定されていますがディレクトリが存在しません: $git_hooks"
  fi
else
  warn "core.hooksPath が未設定（グローバル Git フックが無効。make git-hooks で設定できます）"
fi

# ----------- mise ランタイム -----------
section "mise ランタイム"
if command -v mise >/dev/null 2>&1; then
  for tool in node python go terraform; do
    version=$(mise current "$tool" 2>/dev/null | tr -d '\n' || echo "")
    if [ -n "$version" ]; then
      ok "$tool: $version"
    else
      warn "${tool}: 未インストール（mise install ${tool}）"
    fi
  done
else
  warn "mise が未インストールのためスキップ"
fi

# ----------- Homebrew パッケージ -----------
section "Homebrew パッケージ"
if command -v brew >/dev/null 2>&1; then
  for brewfile_name in Brewfile Brewfile.cask; do
    file="$BASE_DIR/.config/homebrew/$brewfile_name"
    if [ -f "$file" ]; then
      if brew bundle check --file="$file" --quiet 2>/dev/null; then
        ok "$brewfile_name: すべてのパッケージがインストール済み"
      else
        warn "$brewfile_name: 未インストールのパッケージがあります（make brew-bundle でインストール可能）"
      fi
    else
      warn "$brewfile_name: ファイルが見つかりません"
    fi
  done
else
  fail "Homebrew が未インストール（make install を実行してください）"
fi

# ----------- シンボリックリンク -----------
section "シンボリックリンク"
if ! command -v yq >/dev/null 2>&1; then
  warn "yq が未インストールのためスキップ"
else
  apps=$(yq eval 'keys | .[]' "$LINK_MAP" 2>/dev/null || echo "")
  for app in $apps; do
    items=$(yq eval ".$app" "$LINK_MAP")
    check_link() {
      local src="$1" dst="$2"
      local dst_full="$HOME/$dst" src_full="$BASE_DIR/$src"
      if [ -L "$dst_full" ] && [ "$(readlink "$dst_full")" = "$src_full" ]; then
        ok "$dst"
      elif [ -L "$dst_full" ]; then
        fail "$dst → 壊れたリンク（$(readlink "$dst_full")）"
      elif [ -e "$dst_full" ]; then
        warn "$dst → 実ファイルが存在（make backup && make link で解決）"
      else
        fail "$dst → リンクなし（make link を実行してください）"
      fi
    }
    if [[ $(yq eval 'type' <<< "$items") == "!!seq" ]]; then
      while IFS= read -r pair; do
        check_link "$(echo "$pair" | yq eval '.src' -)" "$(echo "$pair" | yq eval '.dst' -)"
      done < <(echo "$items" | yq eval '.[] | @json' -)
    else
      check_link "$(yq eval '.src' <<< "$items")" "$(yq eval '.dst' <<< "$items")"
    fi
  done
fi

# ----------- ネットワーク接続 -----------
section "ネットワーク接続"
if curl -fsSL --max-time 5 https://github.com >/dev/null 2>&1; then
  ok "GitHub への接続"
else
  warn "GitHub への接続失敗（インターネット環境を確認してください）"
fi

if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    gh_user=$(gh api user --jq .login 2>/dev/null || echo "不明")
    ok "GitHub CLI 認証済み（@${gh_user}）"
  else
    warn "GitHub CLI が未認証（gh auth login を実行してください）"
  fi
fi

# ----------- Sheldon プラグイン -----------
section "Sheldon プラグイン"
if command -v sheldon >/dev/null 2>&1; then
  sheldon_data="${XDG_DATA_HOME:-$HOME/.local/share}/sheldon"
  if [ -d "$sheldon_data" ]; then
    plugin_count=$(find "$sheldon_data" -maxdepth 3 -name "*.zsh" 2>/dev/null | wc -l | tr -d ' ')
    ok "sheldon データディレクトリ（約 $plugin_count 件の .zsh ファイル）"
  else
    warn "sheldon データディレクトリが存在しません（make sheldon を実行してください）"
  fi
  lock_file="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.lock"
  if [ -f "$lock_file" ]; then
    ok "plugins.lock が存在します"
  else
    warn "plugins.lock が存在しません（make sheldon を実行してください）"
  fi
fi

# ----------- 結果サマリ -----------
echo
echo "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
printf "  ${GREEN}✓ PASS${RESET}  %d 件\n" "$PASS"
printf "  ${YELLOW}! WARN${RESET}  %d 件\n" "$WARN"
printf "  ${RED}✗ FAIL${RESET}  %d 件\n" "$FAIL"
echo "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo

if [ "$FAIL" -gt 0 ]; then
  echo "${RED}${BOLD}問題が検出されました。上記の FAIL 項目を確認してください。${RESET}"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "${YELLOW}${BOLD}一部警告があります。確認することをお勧めします。${RESET}"
  exit 0
else
  echo "${GREEN}${BOLD}すべてのチェックが通過しました！${RESET}"
  exit 0
fi
