#!/usr/bin/env bash
# my_help.sh - $HOME/.local/bin/scripts にあるスクリプトのヘルプをまとめて表示（かわいく）

set -euo pipefail

SCRIPTS_DIR="${SCRIPTS_DIR:-${HOME}/.local/bin/scripts}"
SHORT=0
USE_COLOR=1
USE_EMOJI=1
GREP_PATTERN=""

usage() {
  cat <<'EOF'
my_help.sh - $HOME/.local/bin/scripts に置いた便利スクリプトのヘルプを集約表示します。

使い方:
  my_help.sh                 # すべてのスクリプトのヘルプ全文を表示
  my_help.sh -s | --short    # 概要だけを一覧表示
  my_help.sh --grep PATTERN  # スクリプト名/ヘルプに PATTERN を含むものだけ表示
  my_help.sh --no-color      # カラー出力を無効化
  my_help.sh --no-emoji      # 絵文字を無効化
  my_help.sh -h | --help     # このヘルプ

環境変数:
  SCRIPTS_DIR  ディレクトリ位置 (default: $HOME/.local/bin/scripts)
  NO_COLOR=1   強制的にカラーを無効化
EOF
}

# ----------- tiny option parser (bash 3.2互換) ------------
if [ "${NO_COLOR:-}" = "1" ]; then
  USE_COLOR=0
fi

ARGS=("$@")
i=0
while [ $i -lt $# ]; do
  arg="${ARGS[$i]}"
  case "$arg" in
    -s|--short) SHORT=1 ;;
    --no-color) USE_COLOR=0 ;;
    --no-emoji) USE_EMOJI=0 ;;
    --grep)
      i=$((i+1))
      [ $i -lt $# ] || { echo "ERROR: --grep requires a pattern" >&2; exit 1; }
      GREP_PATTERN="${ARGS[$i]}"
      ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      # ignore unknown args for now
      ;;
  esac
  i=$((i+1))
done

# ----------- colors / emoji -----------
is_tty=0
[ -t 1 ] && is_tty=1

# shellcheck disable=SC2034  # これらの色は今は未使用だが将来使う可能性がある
if [ $USE_COLOR -eq 1 ] && [ $is_tty -eq 1 ] && command -v tput >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; BLUE="$(tput setaf 4)"
  CYAN="$(tput setaf 6)"; RESET="$(tput sgr0)"
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""; RESET=""
fi

if [ $USE_EMOJI -eq 1 ]; then
  EMO_SCRIPT="📜"
  EMO_SUMMARY="📌"
  EMO_OK="✅"
  EMO_WARN="⚠️"
  EMO_SEP="─"
else
  EMO_SCRIPT="SCRIPT"
  EMO_SUMMARY="SUMMARY"
  EMO_OK="[OK]"
  EMO_WARN="[!]"
  EMO_SEP="-"
fi

# ----------- helpers -----------

die() {
  echo "ERROR: $*" >&2
  exit 1
}

term_width() {
  local w
  w=$( (tput cols 2>/dev/null) || echo 120 )
  echo "$w"
}

hr() {
  local w
  w=$(term_width)
  local i=0
  while [ $i -lt "$w" ]; do
    printf "%s" "$EMO_SEP"
    i=$((i+1))
  done
  printf "\n"
}

try_run() {
  local script="$1"; shift || true
  local out=""
  set +e
  out="$("$script" "$@" 2>/dev/null)"
  local status=$?
  set -e
  if [ $status -eq 0 ] && [ -n "$out" ]; then
    printf "%s" "$out"
    return 0
  fi
  return 1
}

get_help_text() {
  local script="$1"
  local out

  if out=$(try_run "$script" --help); then
    printf "%s\n" "$out"; return 0
  fi
  if out=$(try_run "$script" -h); then
    printf "%s\n" "$out"; return 0
  fi
  if out=$(try_run "$script"); then
    printf "%s\n" "$out"; return 0
  fi
  echo "(no help output detected)"
  return 0
}

extract_summary() {
  local full="$1"
  local line

  line=$(printf "%s\n" "$full" | awk '
    /^[[:space:]]*概要[：:]/ {
      sub(/^[[:space:]]*概要[：:][[:space:]]*/, "", $0); print; exit
    }
    /^[[:space:]]*Description[：:]/ {
      sub(/^[[:space:]]*Description[：:][[:space:]]*/, "", $0); print; exit
    }')
  if [ -n "$line" ]; then
    printf "%s" "$line"
    return 0
  fi

  line=$(printf "%s\n" "$full" | awk 'NF{print; exit}')
  printf "%s" "$line"
}

match_grep() {
  local text="$1"
  if [ -z "$GREP_PATTERN" ]; then
    return 0
  fi
  printf "%s" "$text" | grep -i -q "$GREP_PATTERN"
}

# ----------- main -----------

[ -d "$SCRIPTS_DIR" ] || die "ディレクトリが存在しません: $SCRIPTS_DIR"

scripts=()
for script in "$SCRIPTS_DIR"/*; do
  [ -f "$script" ] && [ -x "$script" ] && scripts+=("$script")
done
if [ ${#scripts[@]} -gt 0 ]; then
  sorted=()
  while IFS= read -r s; do
    sorted+=("$s")
  done < <(printf '%s\n' "${scripts[@]}" | sort)
  scripts=("${sorted[@]}")
fi

if [ ${#scripts[@]} -eq 0 ]; then
  echo "実行可能なスクリプトがありませんでした: $SCRIPTS_DIR"
  exit 0
fi

if [ $SHORT -eq 1 ]; then
  hr
  printf "%s %s%-28s%s  %s\n" "$EMO_SCRIPT" "$BOLD" "SCRIPT" "$RESET" "$EMO_SUMMARY Summary"
  hr
  for script in "${scripts[@]}"; do
    name=$(basename "$script")
    help_text=$(get_help_text "$script")
    # grep フィルタ
    if ! match_grep "$name$help_text"; then
      continue
    fi
    summary=$(extract_summary "$help_text")
    if [ -n "$summary" ]; then
      printf "%s %s%-28s%s  %s\n" "$EMO_OK" "$BOLD" "$name" "$RESET" "$summary"
    else
      printf "%s %s%-28s%s  %s\n" "$EMO_WARN" "$BOLD" "$name" "$RESET" "(no summary)"
    fi
  done
  hr
else
  for script in "${scripts[@]}"; do
    name=$(basename "$script")
    help_text=$(get_help_text "$script")

    # grep フィルタ
    if ! match_grep "$name$help_text"; then
      continue
    fi

    hr
    printf "%s %s%s%s\n" "$EMO_SCRIPT" "$BOLD" "$name" "$RESET"
    hr
    echo "$help_text"
    echo
  done
fi
