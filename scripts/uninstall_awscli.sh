#!/bin/bash

set -euo pipefail

# https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/uninstall.html

usage() {
    cat <<'EOF'
Usage: uninstall_awscli.sh [--purge] [--help]

Options:
  --purge  Remove ~/.aws/ as well as AWS CLI binaries
  --help   Show this help message
EOF
}

purge_aws_config=false

while (($# > 0)); do
    case "$1" in
        --purge)
            purge_aws_config=true
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "不明な引数です: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

if [ "$purge_aws_config" = false ]; then
    usage
    echo
fi

echo "AWS CLIのインストール先を確認しています..."

# command -v でAWS CLIのパスを確認
aws_path=$(command -v aws || true)

if [ -z "$aws_path" ]; then
    echo "AWS CLIはインストールされていません。"
    exit 1
fi

echo "AWS CLIは以下のパスにインストールされています: $aws_path"

# 確認メッセージ
read -r -p "AWS CLIをアンインストールしますか？ (y/N): " confirm
if [[ ! "$confirm" =~ ^[yY]$ ]]; then
    echo "アンインストールをキャンセルしました。"
    exit 0
fi

# インストールディレクトリを確認
install_dir=$(dirname "$aws_path")
echo "AWS CLIのインストールディレクトリ: $install_dir"

# 必要なファイルとディレクトリを削除
echo "AWS CLIのアンインストールを開始します..."

sudo rm -f "$aws_path"
sudo rm -f "${install_dir}/aws_completer"
sudo rm -rf /usr/local/aws-cli

if [ "$purge_aws_config" = true ]; then
    echo "$HOME/.aws/ を削除します..."
    rm -rf "$HOME/.aws/"
fi

# 削除確認
if [ ! -f "$aws_path" ] && [ ! -f "${install_dir}/aws_completer" ] && [ ! -d "/usr/local/aws-cli" ] \
    && { [ "$purge_aws_config" = false ] || [ ! -d "$HOME/.aws/" ]; }; then
    echo "AWS CLIは正常にアンインストールされました。"
else
    echo "AWS CLIの一部がまだ存在する可能性があります。手動で確認してください。"
fi

echo "アンインストールが完了しました。"
exit 0
