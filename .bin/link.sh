#!/bin/zsh
set -e

IGNORE_PATTERN="^\.(git|config|idea)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Create dotfile links."
for dotfile in "${SCRIPT_DIR}"/.??* ; do
    [[ "$dotfile" == "${SCRIPT_DIR}/.git" ]] && continue
    [[ "$dotfile" == "${SCRIPT_DIR}/.github" ]] && continue
    [[ "$dotfile" == "${SCRIPT_DIR}/.DS_Store" ]] && continue

    ln -fnsv "$dotfile" "$HOME"
done

echo "\n========================"
echo "create .config in $HOME"
mkdir -p $HOME/.config
for dotfile in $(find "${SCRIPT_DIR}/config" -type f); do
    [[ $dotfile =~ $IGNORE_PATTERN ]] && continue
    relative_path="${dotfile#"${SCRIPT_DIR}/config/"}"
    target_dir="$HOME/.config/$(dirname "$relative_path")"
    mkdir -p "$target_dir"
    ln -snfv "$dotfile" "$target_dir/$(basename "$dotfile")"
done
