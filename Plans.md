# Plans.md

作成日: 2026-03-29

---

## Phase 1: `.claude/` と `.config/claude/` の役割分離

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 1.1 | `.claude/settings.json` 作成 | ファイルが存在し JSON として valid であること | - | cc:完了 [94db615] |
| 1.2 | `CLAUDE.md` に両ディレクトリの区別を明記 | `.claude/` と `.config/claude/` の役割が読めば分かること | 1.1 | cc:完了 [94db615] |

## Phase 2: GitHub Actions 軽量 PR バリデーション

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 2.1 | `validate.yaml` ワークフロー作成 | PR 時に validate ジョブが pass すること | Phase 1 | cc:完了 [94db615] |

## Phase 3: GitHub Actions macos.yaml 高速化

目標: 12分27秒 → 5分以内

**分析結果（ボトルネック）:**
- Install Homebrew packages: 464s（brew-bundle-cask/vscode が不要なのにCIで実行）
- Cache Homebrew restore: 156s（4.8GBキャッシュが重すぎる）
- install-awscli/gcloud/claude-code: 62s（CIでのdoctor検証に不要）

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 3.1 | `brew-bundle-cask` / `brew-bundle-vscode` を path filter で条件実行（PR時は該当Brewfile変更時のみ、push時は常時） | PRで Brewfile.cask/vscode 未変更時に該当ステップがスキップされること | - | cc:完了 |
| 3.2 | ~~Homebrewキャッシュから `/opt/homebrew/Cellar` を除外~~ | — | — | 却下（Cellar 除外するとキャッシュhit時にCLIインストールが毎回60-90sかかり逆効果。Cellar込みでキャッシュヒット時は restore ~20-30s + install ~5-10s と高速） |
| 3.3 | ~~`install-awscli` / `install-gcloud` / `install-claude-code` をCIでスキップ~~ | — | — | 却下（外部URL依存・.zshenv書き換えロジック等、スクリプトのバグ検出にCIが有効なため） |
| 3.4 | `shellcheck` ジョブと `macos-test` ジョブを並列実行（`needs` 依存を外す） | 2ジョブが並列で動作しCIの総時間が短縮されること | - | cc:完了 |
