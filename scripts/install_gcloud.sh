#!/bin/bash
# install_gcloud.sh - Google Cloud SDK のインストール
# 参考: https://cloud.google.com/sdk/docs/downloads-interactive?hl=ja

set -euo pipefail

GCLOUD_VERSION="${GCLOUD_VERSION:-}"
INSTALL_DIR="${HOME}/google-cloud-sdk"

resolve_gcloud_version() {
  local metadata_url version

  if [ -n "${GCLOUD_VERSION}" ]; then
    printf '%s\n' "${GCLOUD_VERSION}"
    return 0
  fi

  metadata_url="https://dl.google.com/dl/cloudsdk/channels/rapid/components-2.json"

  echo ">>> Google Cloud CLI の最新バージョンを解決しています..." >&2
  version="$(
    curl -fsSL "${metadata_url}" \
      | python3 -c 'import json, sys; data = json.load(sys.stdin); print(data.get("version", ""))'
  )"

  if [ -z "${version}" ]; then
    echo "Google Cloud CLI の最新バージョンを取得できませんでした。" >&2
    echo "必要であれば GCLOUD_VERSION を明示的に指定してください。" >&2
    exit 1
  fi

  printf '%s\n' "${version}"
}

# すでにインストール済みか確認
if command -v gcloud >/dev/null 2>&1; then
  echo "Google Cloud SDK はすでにインストールされています: $(gcloud --version | head -1)"
  echo "更新する場合は 'gcloud components update' を実行してください。"
  exit 0
fi

case "$(arch)" in
  arm64)
    archive_arch="darwin-arm64"
    ;;
  i386|x86_64)
    archive_arch="darwin-x86_64"
    ;;
  *)
    echo "未対応のアーキテクチャです: $(arch)" >&2
    exit 1
    ;;
esac

GCLOUD_VERSION="$(resolve_gcloud_version)"

archive_name="google-cloud-cli-${GCLOUD_VERSION}-${archive_arch}.tar.gz"
archive_url="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${archive_name}"
checksum_url="${archive_url}.sha256"
tmp_dir="$(mktemp -d)"
archive_path="${tmp_dir}/${archive_name}"
checksum_path="${archive_path}.sha256"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

if [ -d "${INSTALL_DIR}" ]; then
  echo "${INSTALL_DIR} がすでに存在するため、インストールを中止します。" >&2
  echo "既存の SDK を削除するか、PATH を確認してください。" >&2
  exit 1
fi

echo ">>> Google Cloud SDK ${GCLOUD_VERSION} をダウンロードしています..."
curl -fsSI "${archive_url}" >/dev/null
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

echo ">>> アーカイブを展開しています..."
tar -xzf "${archive_path}" -C "${HOME}"

echo ">>> Google Cloud SDK をインストールしています..."
"${INSTALL_DIR}/install.sh" --quiet

echo ""
echo ">>> インストール完了。以下を実行して初期化してください:"
echo "    exec -l \$SHELL"
echo "    gcloud init"
