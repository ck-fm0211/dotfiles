#!/bin/bash
# install_gcloud.sh - Google Cloud SDK のインストール
# 参考: https://cloud.google.com/sdk/docs/downloads-interactive

set -euo pipefail

INSTALLER_URL="https://sdk.cloud.google.com"

# すでにインストール済みか確認
if command -v gcloud >/dev/null 2>&1; then
  echo "Google Cloud SDK はすでにインストールされています: $(gcloud --version | head -1)"
  echo "更新する場合は 'gcloud components update' を実行してください。"
  exit 0
fi

tmp_dir="$(mktemp -d)"
installer_path="${tmp_dir}/gcloud_install.sh"

cleanup() { rm -rf "${tmp_dir}"; }
trap cleanup EXIT

# インストーラをファイルに保存（curl | bash を回避）
echo ">>> Google Cloud SDK のインストーラをダウンロードしています..."
curl -fsSL -o "${installer_path}" "${INSTALLER_URL}"

# ダウンロードしたスクリプトの SHA256 をログ出力（監査用）
installer_checksum="$(shasum -a 256 "${installer_path}" | awk '{print $1}')"
echo ">>> Installer SHA256: ${installer_checksum}"

# シェルスクリプトであることの最低限チェック
if ! head -1 "${installer_path}" | grep -q '^#!'; then
  echo "エラー: ダウンロードしたファイルはシェルスクリプトではありません。" >&2
  exit 1
fi

echo ">>> Google Cloud SDK をインストールしています..."
bash "${installer_path}" --disable-prompts

echo ""
echo ">>> インストール完了。以下を実行して初期化してください:"
echo "    exec -l \$SHELL"
echo "    gcloud init"
