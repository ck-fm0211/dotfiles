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
for dotfile in $(ls -F "${SCRIPT_DIR}"/config | grep -v /); do
    [[ $dotfile =~ $IGNORE_PATTERN ]] && continue
    ln -snfv "${SCRIPT_DIR}/config/$dotfile" "$HOME/.config/$dotfile"
done
