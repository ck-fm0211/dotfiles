#!/bin/bash
# install_awscli.sh - AWS CLI v2 のインストール
# 参考: https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/getting-started-install.html

set -euo pipefail

PKG_PATH="/tmp/AWSCLIV2.pkg"

# すでにインストール済みか確認
if command -v aws >/dev/null 2>&1; then
  echo "AWS CLI はすでにインストールされています: $(aws --version)"
  echo "更新する場合は同じコマンドで上書きインストールできます。続行します..."
fi

echo ">>> AWS CLI v2 をダウンロードしています..."
curl --retry 3 --retry-delay 2 -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "$PKG_PATH"

echo ">>> インストールしています..."
sudo installer -pkg "$PKG_PATH" -target /

# 一時ファイルを削除
rm -f "$PKG_PATH"

echo ">>> インストール完了: $(aws --version)"
