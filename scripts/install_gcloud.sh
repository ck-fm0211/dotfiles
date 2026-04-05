#!/bin/bash
# install_gcloud.sh - Google Cloud SDK のインストール
# 参考: https://cloud.google.com/sdk/docs/downloads-interactive?hl=ja

set -euo pipefail

# すでにインストール済みか確認
if command -v gcloud >/dev/null 2>&1; then
  echo "Google Cloud SDK はすでにインストールされています: $(gcloud --version | head -1)"
  echo "更新する場合は 'gcloud components update' を実行してください。"
  exit 0
fi

echo ">>> Google Cloud SDK をインストールしています..."
curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts

echo ""
echo ">>> インストール完了。以下を実行して初期化してください:"
echo "    exec -l \$SHELL"
echo "    gcloud init"
