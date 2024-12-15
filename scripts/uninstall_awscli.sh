#!/bin/zsh

set -e

# https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/uninstall.html

echo "AWS CLIのインストール先を確認しています..."

# whichコマンドでAWS CLIのパスを確認
aws_path=$(which aws)

if [ -z "$aws_path" ]; then
    echo "AWS CLIはインストールされていません。"
    exit 1
fi

echo "AWS CLIは以下のパスにインストールされています: $aws_path"

# 確認メッセージ
read "?AWS CLIをアンインストールしますか？ (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "アンインストールをキャンセルしました。"
    exit 0
fi

# インストールディレクトリを確認
install_dir=$(dirname "$aws_path")
echo "AWS CLIのインストールディレクトリ: $install_dir"

# 必要なファイルとディレクトリを削除
echo "AWS CLIのアンインストールを開始します..."

sudo rm "$aws_path"
sudo rm "${install_dir}/aws_completer"
sudo rm -rf /usr/local/aws-cli
sudo rm -rf ~/.aws/

# 削除確認
if [ ! -f "$aws_path" ] && [ ! -f "${install_dir}/aws_completer" ] && [ ! -d "/usr/local/aws-cli" ] && [ ! -d "~/.aws/" ]; then
    echo "AWS CLIは正常にアンインストールされました。"
else
    echo "AWS CLIの一部がまだ存在する可能性があります。手動で確認してください。"
fi

echo "アンインストールが完了しました。"
exit 0
