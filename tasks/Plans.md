# dotfiles 課題・改善ロードマップ Plans.md

作成日: 2026-04-03
更新日: 2026-04-04

---

## 背景・目的

Codex による網羅的リポジトリ分析で洗い出した課題を優先度別に整理し、改善を計画的に進める。
分析観点: セキュリティ / 冪等性 / 保守性 / パフォーマンス / CI/CD / 依存管理 / クロスプラットフォーム / XDG / ドキュメント / Claude Code 設定

---

## Phase 1: 高優先度（セキュリティ・安定性）

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 1.1 | `scripts/install_gcloud.sh` の `curl \| bash` に SHA256 検証を追加する（**Homebrew 管理へは移行しない** — 公式インストール手順を維持する方針） | ダウンロード後に `sha256sum` でアーカイブを検証してから展開している | - | cc:完了 [d9cfcab] |
| 1.2 | `scripts/install_claude_code.sh` の `curl \| bash` に SHA256 検証を追加する（**Homebrew 管理へは移行しない** — 公式インストール手順を維持する方針） | `sha256sum` コマンドでダウンロード物の検証が通ることをスクリプト内で確認している | - | cc:完了 [d9cfcab] |
| 1.3 | `scripts/uninstall_awscli.sh` の `~/.aws/` 削除確認フローを実コードに合わせて説明を修正し、誤操作しにくい明示的な purge 操作へ改善する（現状は y/N 確認後に削除、**Homebrew 管理へは移行しない**） | `~/.aws/` の削除は通常アンインストール経路から分離され、`--purge` 相当の明示操作なしでは削除されない。課題説明が実装の挙動と一致している | - | cc:完了 [d9cfcab] |
| 1.4 | `scripts/mcp_setup.sh` の env_flags を配列化してシェルメタ文字インジェクションリスクを排除 | `shellcheck` が通り、`SC2086` 抑止コメントが不要になる | - | cc:TODO |
| 1.5 | `scripts/install.sh` の Rosetta 導入済み判定を追加し、`/etc/zshenv` 変更を明示タスクへ分離 | 再実行時に Rosetta 重複インストールを試みない | - | cc:TODO |
| 1.6 | `scripts/install.sh` の `~/.config/zsh/.zshrc` 追記を削除する。`make link` で symlink 化された後は無効になるため | bootstrap フロー完了後に余分な追記が残らない | 1.5 | cc:TODO |
| 1.6b | `scripts/install_claude_code.sh` の `.zshenv` 追記を見直す。symlink 展開後に副作用を持つため、bootstrap 時の一時追記を廃止するか永続設定の置き場所を一本化する | `install_claude_code.sh` 実行後に symlink 展開と競合する `.zshenv` 追記が残らず、設定反映経路が `make link` 後も一貫している | 1.5 | cc:TODO |
| 1.7 | `.config/mise/config.toml` の `python/go/terraform = "latest"` と `node = "lts"` をバージョン固定に変更 | major/minor が固定されており、CI で再現性が担保される | - | cc:TODO |
| 1.8 | `.config/sheldon/plugins.toml` の `kubectl-completion` を commit SHA 固定 URL に変更 | master ブランチ追従でなくなる | - | cc:TODO |
| 1.9 | `.config/git/config` の `user.name`/`user.email` を個人固定値から切り離し、`.local` 側 or 対話入力に移行（`make link` で即展開されるため緊急度が高い） | 別人の環境で適用しても個人情報がコミットされない | - | cc:TODO |

## Phase 2: CI・依存管理の整合性

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 2.1 | CI の shellcheck ジョブを `make shellcheck` 呼び出しに統一する | CI と `make shellcheck` のカバレッジが一致する | - | cc:完了 |
| 2.2 | CI の `make doctor \|\| true` を修正する。WARN/FAIL を分離して FAIL だけ CI を落とす | `make doctor` の失敗が CI で検知される | - | cc:完了 |
| 2.3 | `make setup`・`doctor.sh`・`brew bundle check` の対象を Brewfile 群（mas/vscode/taps/cask 含む）すべてに拡張する | `make doctor` が全 Brewfile を検証する | - | cc:完了 |
| 2.4 | PR テンプレートの shellcheck コマンドを `make shellcheck` に統一する | PR テンプレートの手順がローカルと一致する | 2.1 | cc:完了 |
| 2.5 | `mcp-setup` が CI に存在しない点を整理し、意図的除外か追加対応かを明文化する。可能なら CI 用の検証経路を追加する | README または CI 設計メモに `mcp-setup` の CI 対象可否と理由が明記され、対象化する場合は CI 上で最低限の検証が実行される | - | cc:完了 |

## Phase 3: XDG 準拠・ドキュメント整合

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 3.1 | `scripts/mac_defaults.sh` の `~/screenshots` を `XDG_PICTURES_DIR` 等 XDG 仕様パスへ移動 | `~` 直下にスクリーンショットディレクトリが作られない | - | cc:完了 [fc32185] |
| 3.2 | `scripts/backup.sh` の `~/.dotfiles-backup` を `$XDG_STATE_HOME/dotfiles` 等へ移動 | バックアップが XDG 仕様パスに作られる | - | cc:完了 [fc32185] |
| 3.3 | Python 履歴パスの不整合を修正する。`~/.local/state/python/history` に統一する | `install.sh` と `pythonrc` が同じパスを参照している | - | cc:完了 [fc32185] |
| 3.4 | `~/.config/zsh/.zshrc` の gcloud 読み込みを `command -v gcloud` ベースに変更し、補完を lazy load 化する | gcloud 未インストール環境でのシェル起動が失敗しない | - | cc:完了 [fc32185] |
| 3.5 | README の bootstrap 説明と `bootstrap.sh` 実挙動の差異を修正する。`mise-install`・`git-hooks`・`mcp-setup` の扱いを明確化する | README の手順通りに実行して、CLAUDE.md の `make setup` 全ステップが通る | 2.5 | cc:完了 [fc32185] |

## Phase 4: パフォーマンス・保守性

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 4.1 | `compinit` の二重初期化を解消する。`completion.zsh` と `plugins.compinit` のどちらか一方に集約する | シェル起動時に `compinit` が 1 回だけ呼ばれる | - | cc:完了 [d9cfcab] |
| 4.2 | `.config/zsh/alias.zsh` の標準コマンド名上書き（`grep/find/date` 等）を最小化する。短縮 alias に寄せる | 標準コマンド名がそのまま動作する（alias 解除なしで） | - | cc:完了 [d9cfcab] |
| 4.3 | VSCode 設定（JSONC）の CI バリデーションを整備する。JSONC 用バリデータ追加または README に明記する | `validate.yaml` の特別除外ロジックがなくなる、またはドキュメント化される | - | cc:完了 [d9cfcab] |

## Phase 5: Claude Code / MCP 設定

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 5.1 | `.config/claude/settings.json` の `Bash(make:*)` 全面許可の意図をドキュメントに明記する、または make サブコマンド単位で絞る | 「make 経由は deny をバイパスできる」という事実が CLAUDE.md に記載されている | - | cc:完了 [b626e51] |
| 5.2 | `scripts/mcp_setup.sh` の既登録判定を機械可読出力ベースに変更し、差分更新・削除まで対応する同期型に改善する | `claude mcp list` の出力形式変更に左右されない判定になる | 5.3 | cc:完了 [b626e51] |
| 5.3 | `scripts/mcp_dump.sh` に機密フィールド除外の `jq` フィルタを明示追加し、README にも注意事項を記載する | dump 結果に `oauthAccount` 等の機密フィールドが含まれないことを保証 | 5.2 | cc:完了 [b626e51] |

---

## 優先度サマリー

| 優先度 | フェーズ | 主な課題 |
|--------|----------|----------|
| 最高 | Phase 1 | セキュリティ、認証情報・個人情報保護、冪等性 |
| 高 | Phase 2 | CI/CD と依存管理の整合性 |
| 中 | Phase 3 | XDG 準拠・ドキュメント整合 |
| 低 | Phase 4 | パフォーマンス・保守性 |
| 低 | Phase 5 | Claude Code / MCP 設定の改善 |

---

## フェーズ間の順序制約

- 1.1 の Homebrew 化は 2.1 の CI 変更と連動して扱う
- 1.1 完了後に 3.4 の gcloud 読み込み条件見直しを行う
- 2.5 で `mcp-setup` の CI 上の扱いを定めてから 3.5 の README 整備に反映する
- 5.2 と 5.3 は相互依存のため、同一 PR または同一リリース単位で整合を取る

---

## 設計メモ

### CLI ツールのインストール方針
- **gcloud / Claude Code / AWS CLI は Homebrew 管理にしない** — 各ツールの公式インストール手順（`install_gcloud.sh` / `install_claude_code.sh` / `install_awscli.sh`）を維持する。バージョン管理・アップデート・アンインストールの手順が公式と一致することを優先する。
- 上記ツールの `curl | bash` に対して AI が「Homebrew 管理へ移行せよ」と提案することは方針違反。改善すべきは **SHA256 検証の追加**のみ。
- Homebrew インストーラ自体は `curl | bash` だが、これは bootstrap フェーズで一度だけ許容する前提とする。個別ツール導入スクリプトでは同方式を増やさない
- `tasks/Plans.md` の完了タスク整理は個別タスクではなく運用ルールとして扱う。完了時に `Status` 更新または別ファイルへのアーカイブを都度実施する
- `mcp-setup` はローカル依存や認証状態の影響を受けやすいため、CI 対象外とする場合は理由を明文化する

---

## 分析メモ（Codex による指摘 2026-04-03 / plan-critic 反映済み 2026-04-04）

### 重要度「高」の指摘
- `curl | bash` リスク: `install_gcloud.sh`・`install_claude_code.sh`
- `~/.aws/` 誤削除リスク: `uninstall_awscli.sh`
- make 経由の deny バイパス: `settings.json`
- mise の `latest` / `lts` 指定: 再現性がない
- CI の shellcheck カバレッジ不一致
- Brewfile 部分検証: setup/doctor が全 Brewfile を見ていない
- README vs bootstrap.sh の乖離
- `.config/git/config` の個人情報が `make link` で即展開される

### VSCode 設定は JSONC
`.config/vscode/settings.json`・`keybindings.json` はコメント付き JSONC。
`validate.yaml` で特別除外されているため、JSONC バリデータ導入か明文化が必要。
