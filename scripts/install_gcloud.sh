#!/bin/zsh

set -e

# https://cloud.google.com/sdk/docs/downloads-interactive?hl=ja
curl https://sdk.cloud.google.com > /tmp/install.sh
bash /tmp/install.sh --disable-prompts

# 初期化に関する操作を表示
echo "shellを再起動し、gcloudコマンドがインストールされたことを確認してください。"
echo "実行コマンド:"
echo "exec -l \$SHELL"
echo "which gcloud"
echo "gcloud init"
