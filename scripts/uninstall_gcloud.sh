#!/bin/bash
# uninstall_gcloud.sh - Google Cloud SDK のアンインストール
# 参考: https://cloud.google.com/sdk/docs/uninstall-cloud-sdk?hl=ja

set -euo pipefail

echo "gcloud のインストール先を確認しています..."

if ! command -v gcloud >/dev/null 2>&1; then
  echo "gcloud がインストールされていないか、PATH が通っていません。"
  exit 1
fi

gcloud_path=$(gcloud info --format='value(installation.sdk_root)')
gcloud_config_path=$(gcloud info --format='value(config.paths.global_config_dir)')

echo "SDK インストール先:  $gcloud_path"
echo "設定ディレクトリ:    $gcloud_config_path"

read -r -p "gcloud をアンインストールしますか？ (y/N): " confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
  echo "アンインストールをキャンセルしました。"
  exit 0
fi

echo ">>> アンインストールを開始します..."

rm -rf "$gcloud_path"
echo "  ✓ SDK を削除しました: $gcloud_path"

rm -rf "$gcloud_config_path"
echo "  ✓ 設定を削除しました: $gcloud_config_path"

# キャッシュを削除（エラーは無視）
echo ">>> キャッシュを削除しています..."
find ~/Library/Caches/ -type d -name "google-cloud-sdk" -print0 2>/dev/null \
  | xargs -0 rm -rf 2>/dev/null || true
echo "  ✓ キャッシュを削除しました"

echo ""
echo ">>> アンインストール完了。"
echo "    ~/.zshrc や ~/.zshenv に gcloud の PATH 設定が残っている場合は手動で削除してください。"
exit 0
