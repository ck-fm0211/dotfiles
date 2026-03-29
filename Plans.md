# Plans.md

作成日: 2026-03-29

---

## Phase 1: `.claude/` と `.config/claude/` の役割分離

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 1.1 | `.claude/settings.json` 作成 | ファイルが存在し JSON として valid であること | - | cc:TODO |
| 1.2 | `CLAUDE.md` に両ディレクトリの区別を明記 | `.claude/` と `.config/claude/` の役割が読めば分かること | 1.1 | cc:TODO |

## Phase 2: GitHub Actions 軽量 PR バリデーション

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 2.1 | `validate.yaml` ワークフロー作成 | PR 時に validate ジョブが pass すること | Phase 1 | cc:TODO |
