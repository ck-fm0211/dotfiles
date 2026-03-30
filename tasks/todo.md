# Powerlevel10k instant prompt 警告修正

作成日: 2026-03-30

---

## 問題

ターミナル起動時に以下の警告が毎回表示される:

```
[WARNING]: Console output during zsh initialization detected.
-- console output produced during zsh initialization follows --
mise WARN  missing: node@24.14.1
mise WARN  missing: node@24.14.1
```

---

## 原因分析

### 直接原因
`mise activate zsh` が p10k instant prompt の初期化後にコンソール出力を行っている。

p10k の instant prompt は `.zshrc` の**先頭**でキャッシュを読み込む。
その後に実行される `eval "$(sheldon source)"` の中で `mise activate zsh` が呼ばれ、
node が未インストールのため `WARN missing: node@24.14.1` が stderr に出力される。

### 根本原因
`make setup` のフローに `mise install` が含まれていない。
そのため、新規マシンや LTS バージョンが上がった場合にツールが未インストール状態になる。

### 警告が2回出る理由
iTerm2 などのターミナルアプリがログインシェルと対話シェルを別々に起動するため、
`.zshrc` が2回評価される可能性がある（要確認）。

---

## 対策

### 必須対応（根本解決）

| # | 対応 | ファイル | 優先度 |
|---|------|---------|--------|
| 1 | `make setup` に `mise install` ターゲットを追加 | `Makefile` | 高 |
| 2 | CI の macOS Setup Test でも `mise install` が実行されるか確認 | `.github/workflows/macos.yaml` | 高 |

### 推奨対応（防衛的対策）

| # | 対応 | ファイル | 優先度 |
|---|------|----------|--------|
| 3 | `plugins.toml` の mise activation で stderr を抑制 | `.config/sheldon/plugins.toml` | 中 |

**変更案（Option 3）:**
```toml
# 変更前
[plugins.mise]
inline = 'command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"'

# 変更後
[plugins.mise]
inline = 'command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh 2>/dev/null)"'
```
> これは症状を隠す対処療法。根本解決（対応1・2）を先に実施すること。

### 不要な重複の整理（任意）

`.zshrc` の `brew shellenv` は `plugins.toml` の `[plugins.homebrew]` と重複しているが、
これは**意図的なブートストラップ**（sheldon 自体を見つけるために PATH が必要）なので変更不要。

---

## チェックリスト

- [x] `make setup` に `mise install` ターゲットを追加（Makefile 変更）
- [x] CI で `mise install` が実行されるか確認・追加（macos.yaml）
- [x] （任意）plugins.toml に stderr 抑制を追加
- [ ] ローカルで `mise install` を実行して警告が消えることを確認
- [ ] `make doctor` で node が green になることを確認

---

## レビューセクション

<!-- 作業完了後にここに結果を記録する -->
