---
name: dotfiles リポジトリ固有の依存パターン
description: このリポジトリで繰り返し現れる実装上の依存構造と注意点
type: project
---

## make link 後のシンボリックリンク展開問題

`make link` 完了後、`.config/zsh/.zshenv` 等はシンボリックリンクになりリポジトリ管理ファイルを指す。
この後に `install_claude_code.sh` 等が `.zshenv` に追記すると、リポジトリ管理ファイルへの直接追記になる。

**Why:** `install.sh` が bootstrap フロー初期に `make link` より前に実行されることもあるため、追記タイミングによって挙動が変わる。

**How to apply:** `install_*.sh` が設定ファイルに追記する処理を含む場合、`make link` の前後どちらで実行されるかを確認し、シンボリックリンク化後の副作用を DoD に含めること。

---

## Homebrew の curl | bash は例外扱い

`install.sh` の Homebrew 自体のインストールも `curl | bash` だが、これは業界標準手順として許容されている。
タスクで `curl | bash` を問題視する際は、Homebrew インストーラを対象外とする理由を Plans.md に明記すること。

**Why:** 一貫性がないと「なぜこれはよくてあれはダメか」が不明になり、コードレビューで指摘を受ける。

---

## CI の macos.yaml は make setup と完全一致しない

`make setup` に含まれる `mcp-setup` ステップが CI に存在しない。
CI ステップと `make setup` の差分は意図的な場合（認証必要・対話的操作）と漏れの場合がある。

**How to apply:** CI のカバレッジに関するタスクを計画する際は、`make setup` の全ステップと CI ステップを突き合わせて意図的な除外かどうかを確認する。

---

## doctor.sh の終了コード設計

`doctor.sh` は FAIL > 0 のとき exit 1、WARN のみのとき exit 0 を返す（すでに分離済み）。
`make doctor || true` を除去するだけで CI が FAIL を検知できる状態になっている。

**How to apply:** 「WARN/FAIL を分離する」タスクを計画に含める場合は、実装が既に完了しているか確認すること。
