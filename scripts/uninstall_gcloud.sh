#!/bin/zsh

set -e

# https://cloud.google.com/sdk/docs/uninstall-cloud-sdk?hl=ja

echo "gcloudのインストール先を確認しています..."

# whichコマンドでgcloudのパスを確認
gcloud_path=$(gcloud info --format='value(installation.sdk_root)')
gcloud_config_path=$(gcloud info --format='value(config.paths.global_config_dir)')

echo "gcloudおよび設定は以下のパスにインストールされています:"
echo "$gcloud_path"
echo "$gcloud_config_path"

# 確認メッセージ
read "?gcloudをアンインストールしますか？ (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "アンインストールをキャンセルしました。"
    exit 0
fi

# 必要なファイルとディレクトリを削除
echo "gcloudのアンインストールを開始します..."

rm -rf "$gcloud_path"
rm -rf "$gcloud_config_path"

# キャッシュを削除
echo "キャッシュファイルを削除します。permission errorが出る可能性がありますが問題ありません"
find ~/Library/Caches/ -type d -name "google-cloud-sdk" | xargs rm -r

echo "アンインストールが完了しました。"
exit 0
