#!/bin/bash
# doctor.sh - dotfiles 環境の健全性チェック

set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LINK_MAP="$BASE_DIR/.config/link_map.yaml"

# ----------- 色の設定 -----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  GREEN="$(tput setaf 2)"
  RED="$(tput setaf 1)"
  YELLOW="$(tput setaf 3)"
  BOLD="$(tput bold)"
  RESET="$(tput sgr0)"
else
  GREEN=""; RED=""; YELLOW=""; BOLD=""; RESET=""
fi

PASS=0
FAIL=0
WARN=0

ok()   { echo "  ${GREEN}✓${RESET} $*"; PASS=$((PASS+1)); }
fail() { echo "  ${RED}✗${RESET} $*"; FAIL=$((FAIL+1)); }
warn() { echo "  ${YELLOW}!${RESET} $*"; WARN=$((WARN+1)); }
section() { echo; echo "${BOLD}$*${RESET}"; echo "$(printf '─%.0s' $(seq 1 50))"; }

# ----------- XDG ディレクトリ -----------
section "XDG Base Directories"
for dir in "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" "$HOME/.local/state"; do
  if [ -d "$dir" ]; then
    ok "$dir"
  else
    fail "$dir (存在しません)"
  fi
done

if grep -q "ZDOTDIR" /etc/zshenv 2>/dev/null; then
  ok "/etc/zshenv に ZDOTDIR が設定されています"
else
  fail "/etc/zshenv に ZDOTDIR が未設定（make install を実行してください）"
fi

# ----------- 必須コマンド -----------
section "必須コマンド"
REQUIRED_CMDS=(brew git zsh yq sheldon mise)
for cmd in "${REQUIRED_CMDS[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    version=$(eval "$cmd --version 2>/dev/null | head -1" || echo "")
    ok "$cmd $([ -n "$version" ] && echo "($version)")"
  else
    fail "$cmd がインストールされていません"
  fi
done

# ----------- 推奨コマンド -----------
section "推奨コマンド"
RECOMMENDED_CMDS=(bat eza jq peco colordiff shellcheck gdate gsed)
for cmd in "${RECOMMENDED_CMDS[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd"
  else
    warn "$cmd が未インストール（brew install でインストール可能）"
  fi
done

# ----------- クラウドツール -----------
section "クラウドツール"
CLOUD_CMDS=(aws gcloud claude)
for cmd in "${CLOUD_CMDS[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd"
  else
    warn "$cmd が未インストール（make install-$(echo "$cmd" | sed 's/aws/awscli/' | sed 's/gcloud/gcloud/' | sed 's/claude/claude-code/') でインストール可能）"
  fi
done

# ----------- シンボリックリンク -----------
section "シンボリックリンク"
if ! command -v yq >/dev/null 2>&1; then
  warn "yq が未インストールのため、シンボリックリンクの確認をスキップします"
else
  apps=$(yq eval 'keys | .[]' "$LINK_MAP" 2>/dev/null || echo "")
  for app in $apps; do
    items=$(yq eval ".$app" "$LINK_MAP")
    if [[ $(yq eval 'type' <<< "$items") == "!!seq" ]]; then
      for pair in $(echo "$items" | yq eval '.[] | @json' -); do
        src=$(echo "$pair" | yq eval '.src' -)
        dst=$(echo "$pair" | yq eval '.dst' -)
        dst_full="$HOME/$dst"
        src_full="$BASE_DIR/$src"
        if [ -L "$dst_full" ] && [ "$(readlink "$dst_full")" = "$src_full" ]; then
          ok "$dst -> $src"
        elif [ -L "$dst_full" ]; then
          fail "$dst -> シンボリックリンクが壊れています（$(readlink "$dst_full")）"
        elif [ -e "$dst_full" ]; then
          warn "$dst -> シンボリックリンクではなく実ファイルが存在します（make link で上書きされます）"
        else
          fail "$dst -> シンボリックリンクが存在しません（make link を実行してください）"
        fi
      done
    else
      src=$(yq eval '.src' <<< "$items")
      dst=$(yq eval '.dst' <<< "$items")
      dst_full="$HOME/$dst"
      src_full="$BASE_DIR/$src"
      if [ -L "$dst_full" ] && [ "$(readlink "$dst_full")" = "$src_full" ]; then
        ok "$dst -> $src"
      elif [ -L "$dst_full" ]; then
        fail "$dst -> シンボリックリンクが壊れています"
      elif [ -e "$dst_full" ]; then
        warn "$dst -> 実ファイルが存在します（make link で上書きされます）"
      else
        fail "$dst -> シンボリックリンクが存在しません"
      fi
    fi
  done
fi

# ----------- Homebrew -----------
section "Homebrew パッケージ"
if command -v brew >/dev/null 2>&1; then
  for brewfile in Brewfile Brewfile.cask; do
    file="$BASE_DIR/.config/homebrew/$brewfile"
    if [ -f "$file" ]; then
      if brew bundle check --file="$file" --quiet 2>/dev/null; then
        ok "$brewfile: すべてのパッケージがインストール済み"
      else
        warn "$brewfile: 未インストールのパッケージがあります（make brew-bundle でインストール可能）"
      fi
    fi
  done
else
  warn "Homebrew が未インストールのためスキップします"
fi

# ----------- 結果サマリ -----------
echo
echo "${BOLD}─── 診断結果 ───────────────────────────────────────${RESET}"
echo "  ${GREEN}✓ PASS${RESET}  $PASS"
echo "  ${YELLOW}! WARN${RESET}  $WARN"
echo "  ${RED}✗ FAIL${RESET}  $FAIL"
echo

if [ "$FAIL" -gt 0 ]; then
  echo "${RED}${BOLD}問題が検出されました。上記の FAIL 項目を確認してください。${RESET}"
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo "${YELLOW}${BOLD}警告があります。確認することをお勧めします。${RESET}"
  exit 0
else
  echo "${GREEN}${BOLD}すべてのチェックが通過しました！${RESET}"
  exit 0
fi
