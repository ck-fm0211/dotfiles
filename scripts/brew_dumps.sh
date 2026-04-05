#!/bin/bash
# brew_dumps.sh - 現在の Homebrew インストール状態を Brewfile にスマートマージ
#
# 既存ファイルのコメント・カテゴリ構造を保持したまま、
# 新規追加エントリのみを末尾に追記する。
# 削除候補（インストール済みリストから消えたエントリ）は警告表示のみ行い、
# 手動での対応を促す。

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/homebrew"
TMPDIR="${TMPDIR:-/tmp}"
TODAY=$(date +%Y-%m-%d)

# 一時ファイルを作成し、スクリプト終了時に自動削除する
TMPFILE_BREWS=$(mktemp "${TMPDIR}/brew_dump_brews.XXXXXX")
TMPFILE_CASK=$(mktemp "${TMPDIR}/brew_dump_cask.XXXXXX")
TMPFILE_TAPS=$(mktemp "${TMPDIR}/brew_dump_taps.XXXXXX")
TMPFILE_MAS=$(mktemp "${TMPDIR}/brew_dump_mas.XXXXXX")
TMPFILE_VSCODE=$(mktemp "${TMPDIR}/brew_dump_vscode.XXXXXX")
trap 'rm -f "$TMPFILE_BREWS" "$TMPFILE_CASK" "$TMPFILE_TAPS" "$TMPFILE_MAS" "$TMPFILE_VSCODE"' EXIT

echo ">>> Homebrew の状態を取得します..."
brew bundle dump --force --brews   --file="$TMPFILE_BREWS"
brew bundle dump --force --cask    --file="$TMPFILE_CASK"
brew bundle dump --force --taps    --file="$TMPFILE_TAPS"
brew bundle dump --force --mas     --file="$TMPFILE_MAS"
brew bundle dump --force --vscode  --file="$TMPFILE_VSCODE"
echo "    ✓ 取得完了"
echo ""

# -----------------------------------------------------------------
# extract_names <file> <prefix>
#   Brewfile から各エントリ名（引用符内の文字列）を抽出する
#   例: brew "bat"  → bat
#       cask "iterm2" → iterm2
# -----------------------------------------------------------------
extract_names() {
    local file="$1"
    local prefix="$2"
    grep "^${prefix} " "$file" | sed -E "s/^${prefix} \"([^\"]+)\".*/\1/" | sort
}

# -----------------------------------------------------------------
# merge_brewfile <existing_file> <dump_file> <prefix> <label>
#   既存ファイルと dump の差分を計算し、新規エントリを追記する。
#   削除候補は stderr に警告を出す。
# -----------------------------------------------------------------
merge_brewfile() {
    local existing="$1"
    local dumped="$2"
    local prefix="$3"
    local label="$4"

    # 既存ファイルがなければ dump をそのままコピー
    if [[ ! -f "$existing" ]]; then
        cp "$dumped" "$existing"
        echo "    ✓ ${label}: 新規作成"
        return
    fi

    local existing_names
    existing_names=$(extract_names "$existing" "$prefix")
    local dumped_names
    dumped_names=$(extract_names "$dumped" "$prefix")

    # 新規追加分（dump にあって existing にない）
    local added
    added=$(comm -13 <(echo "$existing_names") <(echo "$dumped_names") || true)

    # 削除候補（existing にあって dump にない）
    local removed
    removed=$(comm -23 <(echo "$existing_names") <(echo "$dumped_names") || true)

    local changed=false

    if [[ -n "$added" ]]; then
        {
            echo ""
            echo "# newly added (${TODAY})"
            while IFS= read -r name; do
                echo "${prefix} \"${name}\""
            done <<< "$added"
        } >> "$existing"
        changed=true
        local count
        count=$(echo "$added" | wc -l | tr -d ' ')
        echo "    ✓ ${label}: ${count} 件追加"
        while IFS= read -r name; do
            echo "       + ${name}"
        done <<< "$added"
    fi

    if [[ -n "$removed" ]]; then
        echo "    ⚠ ${label}: 以下は現在アンインストール済みです（手動で削除してください）:"
        while IFS= read -r name; do
            echo "       - ${name}"
        done <<< "$removed"
    fi

    if [[ "$changed" == false ]] && [[ -z "$removed" ]]; then
        echo "    ✓ ${label}: 変更なし"
    fi
}

# -----------------------------------------------------------------
# merge_taps <existing_file> <dump_file>
#   taps はコメントなしのシンプル構造なのでエントリ単位でマージする
# -----------------------------------------------------------------
merge_taps() {
    local existing="$1"
    local dumped="$2"

    if [[ ! -f "$existing" ]]; then
        cp "$dumped" "$existing"
        echo "    ✓ Brewfile.taps: 新規作成"
        return
    fi

    local existing_taps dumped_taps added removed
    existing_taps=$(grep "^tap " "$existing" | sort || true)
    dumped_taps=$(grep "^tap " "$dumped" | sort || true)

    added=$(comm -13 <(echo "$existing_taps") <(echo "$dumped_taps") || true)
    removed=$(comm -23 <(echo "$existing_taps") <(echo "$dumped_taps") || true)

    if [[ -n "$added" ]]; then
        {
            echo ""
            echo "# newly added (${TODAY})"
            echo "$added"
        } >> "$existing"
        local count
        count=$(echo "$added" | wc -l | tr -d ' ')
        echo "    ✓ Brewfile.taps: ${count} 件追加"
    fi

    if [[ -n "$removed" ]]; then
        echo "    ⚠ Brewfile.taps: 以下は削除候補（手動で確認してください）:"
        while IFS= read -r line; do
            echo "       - ${line}"
        done <<< "$removed"
    fi

    if [[ -z "$added" ]] && [[ -z "$removed" ]]; then
        echo "    ✓ Brewfile.taps: 変更なし"
    fi
}

echo ">>> 差分をマージしています..."
merge_brewfile "$CONFIG_DIR/Brewfile"         "$TMPFILE_BREWS"  "brew"   "Brewfile"
merge_brewfile "$CONFIG_DIR/Brewfile.cask"    "$TMPFILE_CASK"   "cask"   "Brewfile.cask"
merge_brewfile "$CONFIG_DIR/Brewfile.mas"     "$TMPFILE_MAS"    "mas"    "Brewfile.mas"
merge_brewfile "$CONFIG_DIR/Brewfile.vscode"  "$TMPFILE_VSCODE" "vscode" "Brewfile.vscode"
merge_taps     "$CONFIG_DIR/Brewfile.taps"    "$TMPFILE_TAPS"

echo ""
echo ">>> マージ完了。変更をレビューしてコミットしてください:"
echo "    git diff .config/homebrew/"
echo "    git add .config/homebrew/ && git commit -m 'brew: update Brewfiles'"
