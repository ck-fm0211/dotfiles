#!/bin/bash
# install_gcloud.sh - Google Cloud SDK のインストール
# 参考: https://cloud.google.com/sdk/docs/install

set -euo pipefail

INSTALL_DIR="${HOME}/google-cloud-sdk"
BASE_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads"

# すでにインストール済みか確認
if command -v gcloud >/dev/null 2>&1; then
  echo "Google Cloud SDK はすでにインストールされています: $(gcloud --version | head -1)"
  echo "更新する場合は 'gcloud components update' を実行してください。"
  exit 0
fi

# アーキテクチャ判定 (uname -m の方が arch より一貫している)
# macOS: arm64 = Apple Silicon, x86_64 = Intel
case "$(uname -m)" in
  arm64)
    archive_arch="darwin-arm"
    ;;
  x86_64)
    archive_arch="darwin-x86_64"
    ;;
  *)
    echo "未対応のアーキテクチャです: $(uname -m)" >&2
    exit 1
    ;;
esac

# バージョン取得: 環境変数優先、なければ components-2.json から動的取得
if [ -n "${GCLOUD_VERSION:-}" ]; then
  version="${GCLOUD_VERSION}"
else
  echo ">>> Google Cloud CLI の最新バージョンを取得しています..."
  version="$(curl -fsSL "https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("version",""))')"
  if [ -z "${version}" ]; then
    echo "バージョンの取得に失敗しました。GCLOUD_VERSION を指定して再実行してください。" >&2
    exit 1
  fi
fi

archive_name="google-cloud-cli-${version}-${archive_arch}.tar.gz"
archive_url="${BASE_URL}/${archive_name}"
checksum_url="${archive_url}.sha256"

tmp_dir="$(mktemp -d)"
archive_path="${tmp_dir}/${archive_name}"
checksum_path="${archive_path}.sha256"

cleanup() { rm -rf "${tmp_dir}"; }
trap cleanup EXIT

if [ -d "${INSTALL_DIR}" ]; then
  echo "${INSTALL_DIR} がすでに存在するため、インストールを中止します。" >&2
  echo "既存の SDK を削除するか、PATH を確認してください。" >&2
  exit 1
fi

echo ">>> Google Cloud SDK ${version} (${archive_arch}) をダウンロードしています..."
curl -fsSL -o "${archive_path}" "${archive_url}"
curl -fsSL -o "${checksum_path}" "${checksum_url}"

expected_checksum="$(awk '{print $1}' "${checksum_path}")"
actual_checksum="$(shasum -a 256 "${archive_path}" | awk '{print $1}')"

if [ -z "${expected_checksum}" ] || [ "${expected_checksum}" != "${actual_checksum}" ]; then
  echo "SHA256 検証に失敗しました。" >&2
  echo "expected: ${expected_checksum}" >&2
  echo "actual:   ${actual_checksum}" >&2
  exit 1
fi

echo ">>> SHA256 検証が通過しました。アーカイブを展開しています..."
tar -xzf "${archive_path}" -C "${HOME}"

echo ">>> Google Cloud SDK をインストールしています..."
"${INSTALL_DIR}/install.sh" --quiet

echo ""
echo ">>> インストール完了。以下を実行して初期化してください:"
echo "    exec -l \$SHELL"
echo "    gcloud init"
