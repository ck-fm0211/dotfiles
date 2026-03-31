# Claude Code MCP設定のdotfiles管理 Plans.md

作成日: 2026-04-01

---

## 背景・目的

`claude mcp add -s user` でグローバルに追加したMCPサーバーの設定を dotfiles で管理したい。
`.claude.json` はランタイム状態・機密情報（oauthAccount等）が混在するため直接管理不可。
代わりに Brewfile パターンで宣言的設定ファイル + セットアップスクリプトで管理する。

---

## Phase 1: MCP サーバーの宣言的管理

| Task | 内容 | DoD | Depends | Status |
|------|------|-----|---------|--------|
| 1.1 | `.config/claude/mcp-servers.json` を作成（現在の `codex` MCP を記載） | ファイルが存在し、`codex` エントリが正しいJSON形式で記載されている | - | cc:TODO |
| 1.2 | `scripts/mcp_setup.sh` を作成（mcp-servers.json を読んで `claude mcp add -s user` を実行） | `make shellcheck` が通り、冪等実行できる（既登録はスキップ） | 1.1 | cc:TODO |
| 1.3 | Makefile に `make mcp-setup` ターゲットを追加 | `make help` に表示される | 1.2 | cc:TODO |
| 1.4 | `make setup` の依存に `mcp-setup` を追加 | `make setup` を実行すると `mcp_setup.sh` が呼ばれる | 1.3 | cc:TODO |

## Phase 2: keybindings.json の管理準備

| Task | 内容 | DoD | Depends | Status |
|------|------|------|---------|--------|
| 2.1 | `.config/claude/keybindings.json` のプレースホルダーを作成（空の `{}`） | ファイルが存在し、link_map.yaml にエントリが追加されている | Phase 1 | cc:TODO |

---

## 設計メモ

### なぜ `.claude.json` をシンボリックリンクしないか
- `oauthAccount`（メール・UUID）など機密情報が含まれる
- `tipsHistory`, `cachedGrowthBookFeatures` など Claude Code が頻繁に書き換えるランタイム状態が含まれる
- シンボリックリンクすると git が汚れ続ける

### mcp-servers.json フォーマット（案）
`.claude.json` の `mcpServers` セクションと同じ構造を採用し、差分が分かりやすくする:
```json
{
  "codex": {
    "type": "stdio",
    "command": "codex",
    "args": ["mcp-server"],
    "env": {}
  }
}
```

### mcp_setup.sh の冪等性
`claude mcp list` で既登録を確認し、未登録のものだけ `claude mcp add -s user` を実行する。

### `~/.config/claude/` 管理状況まとめ
| ファイル | 管理 | 備考 |
|---------|------|------|
| `settings.json` | ✅ | 権限設定 |
| `CLAUDE.md` | ✅ | 全プロジェクト共通指示 |
| `agents/` | ✅ | カスタムエージェント |
| `keybindings.json` | Phase 2 で追加予定 | Claude Code カスタムキーバインド |
| `.claude.json` | ❌ 管理しない | 機密情報・ランタイム状態混在 |
| `plans/`, `sessions/`, `history.jsonl` | ❌ 管理しない | Claude Code のランタイムデータ |
