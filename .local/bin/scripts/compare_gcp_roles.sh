#!/usr/bin/env bash

# ---- help first (before strict mode) ---------------------------------
usage() {
cat <<'EOF'
概要: Google Cloud のロール(事前定義/カスタム)に含まれる権限を比較します。

使用法:
  compare_roles.sh [OPTIONS] <ROLE_ID1> <ROLE_ID2>

ROLE_ID の指定方法（例）:
  - 事前定義ロール: roles/viewer
  - プロジェクトスコープのカスタムロール: projects/PROJECT_ID/roles/ROLE_NAME
  - 組織スコープのカスタムロール: organizations/ORG_ID/roles/ROLE_NAME
  - フォルダスコープのカスタムロール: folders/FOLDER_ID/roles/ROLE_NAME

  ※ROLE_ID が上記の完全修飾形式でない場合、-P/-O/-F で与えたスコープ情報から
    自動的に "projects/.../roles/ROLE_NAME" 等に補完されます。

オプション:
  -P PROJECT_ID   プロジェクトスコープを指定
  -O ORG_ID       組織スコープを指定
  -F FOLDER_ID    フォルダスコープを指定
                  ※ -P/-O/-F は相互に排他です

  -o MODE         出力形式を指定 (text|json|csv) [default: text]
  -w WIDTH        diff の横幅 (未指定時は端末幅を自動検出)
  -q              冗長なログを抑制 (quiet)
  -h, --help      本ヘルプを表示

出力:
  text: 差分を左右表示（colordiff があれば使用）、共通権限も表示
  json: { only_in_role1:[], only_in_role2:[], common:[] } などを JSON で出力
  csv : permission,where (where は role1_only|role2_only|common)

終了コード:
  - 0: 正常終了（差分あり/なしに関わらず）
  - >0: 実行時エラー

例:
  # 事前定義ロール同士の比較 (デフォルト text モード)
  ./compare_roles.sh roles/viewer roles/editor

  # プロジェクトスコープのカスタムロール比較 (JSON 出力)
  ./compare_roles.sh -P my-proj -o json myCustomRole anotherCustomRole
EOF
}

# ここで --help/-h/引数なし を処理（strict mode 前）
first_arg="${1-}"
if [ "$#" -eq 0 ] || [ "$first_arg" = "-h" ] || [ "$first_arg" = "--help" ]; then
  usage
  exit 0
fi

# long オプション（--help 以外）をここで拾いたければ追加
for arg in "$@"; do
  case "$arg" in
    --help)
      usage
      exit 0
      ;;
  esac
done

set -euo pipefail

#==============================================================
# Google Cloud 事前定義/カスタムロールの権限比較スクリプト
# - スコープ対応（組織/プロジェクト/フォルダ）
# - diff 非ゼロ終了コードの明確化
# - trap 強化
# - getopts でオプション化
# - 端末幅自動検出
# - JSON/CSV 出力モード
# - mktemp にプレフィックス付与
#==============================================================

#----------- Globals -----------
PROJECT_ID=""
ORG_ID=""
FOLDER_ID=""
OUTPUT_MODE="text"   # text|json|csv
WIDTH=""             # auto detect by default
QUIET=0
ROLE1=""
ROLE2=""
DIFF_CMD="diff"

TMP1=""
TMP2=""

#----------- Utils -------------

log() {
  (( QUIET )) && return 0
  echo "$@"
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

cleanup() {
  # shellcheck disable=SC2317  # called via trap
  [[ -n "${TMP1:-}" && -f "$TMP1" ]] && rm -f "$TMP1"
  # shellcheck disable=SC2317  # called via trap
  [[ -n "${TMP2:-}" && -f "$TMP2" ]] && rm -f "$TMP2"
}
trap cleanup EXIT INT TERM

#----------- Option Parse -----------
while getopts ":P:O:F:o:w:qh" opt; do
  case "$opt" in
    P) PROJECT_ID="$OPTARG" ;;
    O) ORG_ID="$OPTARG" ;;
    F) FOLDER_ID="$OPTARG" ;;
    o) OUTPUT_MODE="$OPTARG" ;;
    w) WIDTH="$OPTARG" ;;
    q) QUIET=1 ;;
    h) usage; exit 0 ;;
    \?) die "不正なオプションです: -$OPTARG ( -h でヘルプを表示 )" ;;
    :)  die "オプション -$OPTARG には引数が必要です" ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi
ROLE1="$1"
ROLE2="$2"

#----------- Validations -----------

# 排他チェック
non_empty_scopes=0
[[ -n "$PROJECT_ID" ]]  && ((non_empty_scopes++))
[[ -n "$ORG_ID" ]]      && ((non_empty_scopes++))
[[ -n "$FOLDER_ID" ]]   && ((non_empty_scopes++))

if (( non_empty_scopes > 1 )); then
  die "-P / -O / -F は同時に指定できません"
fi

# gcloud 存在
command -v gcloud >/dev/null 2>&1 || die "gcloud が見つかりません。Cloud SDK をインストールしてください。"

# colordiff 検出
if command -v colordiff >/dev/null 2>&1; then
  DIFF_CMD="colordiff"
  log "colordiff を使用して差分を表示します。"
fi

# 出力形式
case "$OUTPUT_MODE" in
  text|json|csv) ;;
  *) die "--output(-o) は text|json|csv のいずれかを指定してください" ;;
esac

# 端末幅
if [ -z "$WIDTH" ]; then
  WIDTH=$( (tput cols 2>/dev/null) || echo 150 )
fi

# ロケール固定（sort/comm の安定化）
export LC_ALL=C

#----------- Functions -----------

build_full_role_id() {
  local role="$1"
  if [[ "$role" == */* ]]; then
    echo "$role"
    return 0
  fi
  if [[ -z "$PROJECT_ID" && -z "$ORG_ID" && -z "$FOLDER_ID" ]]; then
    echo "$role"
    return 0
  fi
  if [[ -n "$PROJECT_ID" ]]; then
    echo "projects/${PROJECT_ID}/roles/${role}"
  elif [[ -n "$ORG_ID" ]]; then
    echo "organizations/${ORG_ID}/roles/${role}"
  elif [[ -n "$FOLDER_ID" ]]; then
    echo "folders/${FOLDER_ID}/roles/${role}"
  fi
}

check_role_exists() {
  local role_id="$1"
  log "## ロール '$role_id' の存在を確認しています..."
  local cmd="gcloud iam roles describe \"$role_id\" --format=\"value(name)\""
  log "+ $cmd"
  if ! gcloud iam roles describe "$role_id" --format="value(name)" >/dev/null 2>&1; then
    die "ロール '$role_id' が見つからないか、アクセスできません。"
  fi
  log "ロール '$role_id' の存在を確認しました。"
}

get_permissions_to_file() {
  local role_id="$1"
  local outfile="$2"
  log "## $role_id の権限を取得しています..."
  local cmd="gcloud iam roles describe \"$role_id\" --format='value(includedPermissions)'"
  log "+ $cmd"

  gcloud iam roles describe "$role_id" --format='value(includedPermissions)' \
    | tr ';' '\n' \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
    | sed '/^$/d' \
    | sort -u > "$outfile"
}

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

json_array_from_file() {
  local file="$1"
  local first=1
  printf '['
  while IFS= read -r line; do
    local esc
    esc=$(printf "%s" "$line" | json_escape)
    if (( first )); then
      printf "\"%s\"" "$esc"
      first=0
    else
      printf ",\"%s\"" "$esc"
    fi
  done < "$file"
  printf ']'
}

csv_from_lists() {
  local file="$1" label="$2"
  while IFS= read -r line; do
    printf "%s,%s\n" "$line" "$label"
  done < "$file"
}

#----------- Main -----------

ROLE1_FULL=$(build_full_role_id "$ROLE1")
ROLE2_FULL=$(build_full_role_id "$ROLE2")

log "### Google Cloud ロール権限比較"
log ""
log "比較対象ロール:"
log "  1. $ROLE1_FULL"
log "  2. $ROLE2_FULL"
log ""

check_role_exists "$ROLE1_FULL"
check_role_exists "$ROLE2_FULL"
log ""

TMP1=$(mktemp -t rolecmp.1.XXXXXX)
TMP2=$(mktemp -t rolecmp.2.XXXXXX)

get_permissions_to_file "$ROLE1_FULL" "$TMP1"
get_permissions_to_file "$ROLE2_FULL" "$TMP2"

TMP_COMMON=$(mktemp -t rolecmp.common.XXXXXX)
TMP_ONLY1=$(mktemp -t rolecmp.only1.XXXXXX)
TMP_ONLY2=$(mktemp -t rolecmp.only2.XXXXXX)
trap 'rm -f "$TMP1" "$TMP2" "$TMP_COMMON" "$TMP_ONLY1" "$TMP_ONLY2"' EXIT INT TERM

comm -12 "$TMP1" "$TMP2" > "$TMP_COMMON"
comm -23 "$TMP1" "$TMP2" > "$TMP_ONLY1"
comm -13 "$TMP1" "$TMP2" > "$TMP_ONLY2"

case "$OUTPUT_MODE" in
  text)
    log "左 (-): $ROLE1_FULL にのみ存在する権限"
    log "右 (+): $ROLE2_FULL にのみ存在する権限"
    log ""
    set +e
    $DIFF_CMD -y -W "$WIDTH" --suppress-common-lines "$TMP1" "$TMP2"
    diff_status=$?
    set -e
    if [ "$diff_status" -gt 1 ]; then
      die "diff 実行中にエラーが発生しました (exit=$diff_status)"
    fi
    log ""
    if [ ! -s "$TMP_COMMON" ]; then
      log "共通の権限はありませんでした。"
    else
      log "両方のロールに含まれる共通の権限:"
      cat "$TMP_COMMON"
    fi
    log ""
    log "比較が完了しました。"
    ;;

  json)
    printf '{'
    printf '"role1":"%s",' "$(printf "%s" "$ROLE1_FULL" | json_escape)"
    printf '"role2":"%s",' "$(printf "%s" "$ROLE2_FULL" | json_escape)"
    printf '"only_in_role1":'
    json_array_from_file "$TMP_ONLY1"
    printf ','
    printf '"only_in_role2":'
    json_array_from_file "$TMP_ONLY2"
    printf ','
    printf '"common":'
    json_array_from_file "$TMP_COMMON"
    printf '}\n'
    ;;

  csv)
    echo "permission,where"
    csv_from_lists "$TMP_ONLY1" "role1_only"
    csv_from_lists "$TMP_ONLY2" "role2_only"
    csv_from_lists "$TMP_COMMON" "common"
    ;;
esac

exit 0
