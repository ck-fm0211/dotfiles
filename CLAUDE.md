# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## リポジトリ概要

macOS dotfiles を IaC として管理するリポジトリ。`make setup` 一発で新規 Mac を自動セットアップできる。シンボリックリンクの定義は [.config/link_map.yaml](.config/link_map.yaml)（唯一の真実の源）に宣言し、[scripts/link.sh](scripts/link.sh) が `yq` を通じて適用する。

## よく使うコマンド

```bash
make help              # 利用可能なコマンド一覧を表示

# セットアップ
make bootstrap         # 新規 Mac 向け: Homebrew 未インストール状態から一発セットアップ（bootstrap.sh を実行）
make setup             # フルセットアップ: install → link → brew-bundle-taps → brew-bundle → brew-bundle-cask → brew-bundle-vscode → sheldon → mac-defaults → git-hooks → install-awscli → install-gcloud → install-claude-code
make link              # link_map.yaml からシンボリックリンクを作成
make link-dry          # シンボリックリンクの変更プレビュー（書き込みなし）
make unlink            # link.sh が作成したシンボリックリンクをすべて削除

# Homebrew
make brew-bundle       # CLI ツールをインストール (Brewfile)
make brew-bundle-cask  # デスクトップアプリをインストール (Brewfile.cask)
make brew-bundle-vscode # VSCode 拡張機能をインストール (Brewfile.vscode)
make brew-dump         # 現在のインストール状態を Brewfile にエクスポート
make update            # Homebrew + sheldon + mise をまとめてアップデート

# 診断・メンテナンス
make doctor            # 環境ヘルスチェック
make shellcheck        # scripts/ 以下のシェルスクリプトをすべて lint
make clean             # キャッシュを削除 (Homebrew・pip・npm・Go・Docker・Zsh)
make clean-dry         # 削除対象のプレビュー
```

## アーキテクチャ

### シンボリックリンク管理
すべてのシンボリックリンクは [.config/link_map.yaml](.config/link_map.yaml) に `source → target` のペアでカテゴリ別（git・homebrew・sheldon・mise・zsh・iterm2・vscode・python・custom_scripts・bat・ripgrep・claude_code 等）に定義されている。[scripts/link.sh](scripts/link.sh) がこの YAML を `yq` で読み込んでリンクを作成する。新しい dotfile を追加する場合は `link_map.yaml` にエントリを追加するだけでよく、スクリプトにパスをハードコードしない。

### Zsh 設定（モジュール構成）
[.config/zsh/](.config/zsh/) は責務ごとに分割されており、[sheldon](.config/sheldon/plugins.toml) が読み込み順・遅延ロード・テンプレート処理を管理する:
- `.zshenv` — 環境変数（全シェルタイプで読み込まれる）
- `.zshrc` — 対話シェルのエントリポイント
- `path.zsh` — PATH 管理
- `settings.zsh` — Zsh オプション
- `completion.zsh` — 補完スタイル
- `functions.zsh` — カスタム関数
- `alias.zsh` — エイリアス（eza・bat・rg 等モダンツールへの置き換えを含む）
- `bindkey.zsh` — キーバインド

設定全体を通じて XDG Base Directory 仕様（`$XDG_CONFIG_HOME`・`$XDG_STATE_HOME` 等）に準拠している。

### Homebrew 分割 Brewfile
依存パッケージは [.config/homebrew/](.config/homebrew/) に分割管理:
- `Brewfile` — CLI ツール
- `Brewfile.cask` — デスクトップアプリ
- `Brewfile.mas` — Mac App Store アプリ
- `Brewfile.taps` — サードパーティ tap
- `Brewfile.vscode` — VSCode 拡張機能

### ランタイムバージョン管理
[.config/mise/config.toml](.config/mise/config.toml) でグローバルバージョンを固定（Node LTS・Python/Go/Terraform 最新）。プロジェクト単位の上書きは `.mise.toml` で行う。

### Claude Code 設定 — 2 つのディレクトリの区別

このリポジトリには Claude Code 関連のディレクトリが **2 つ**存在する。役割が異なるため混同しないこと。

| ディレクトリ | 役割 | `make link` 後 | 編集すべき場面 |
|---|---|---|---|
| [.config/claude/](.config/claude/) | **グローバル設定のソース**。dotfiles として管理し、シンボリックリンクで `~/.config/claude/` に展開される | `~/.config/claude/` | 全マシン共通の Claude 設定を変更したい時 |
| [.claude/](.claude/) | **このリポジトリ専用のプロジェクト設定**。シンボリックリンクされない。グローバル設定に追加で適用される | ―（変化しない） | このリポジトリで作業する Claude の挙動を調整したい時 |

**ファイルの対応:**

- `.config/claude/settings.json` → `~/.config/claude/settings.json`（グローバル権限設定）
- `.config/claude/CLAUDE.md` → `~/.config/claude/CLAUDE.md`（全プロジェクト共通の Claude 指示）
- `.claude/settings.json` → プロジェクト固有設定（`shellcheck`・`yq` の追加許可など最小限）

**グローバル設定の内容:** `git`・`make`・`brew`・`sheldon`・`mise` の実行を許可し、`rm`・`sudo`・`curl`・`wget`・`.zshrc`/`.bashrc` の編集・`.env` ファイル・秘密鍵・SSH キー・Git 認証情報の読み取りを明示的に禁止している。

## CI

[.github/workflows/macos.yaml](.github/workflows/macos.yaml) は push および PR ごとに 2 つのジョブを順番に実行する:
1. **shellcheck** (Ubuntu) — `scripts/` 配下のシェルスクリプトの構文チェック
2. **macOS Setup Test** — shellcheck 成功後、macOS 上でフルセットアップをエンドツーエンドで実行（`make doctor`・`make shellcheck` も含む）

スクリプト変更をプッシュする前に `make shellcheck` をローカルで実行すること。

## 設計上の制約

- **冪等性**: すべてのセットアップコマンドは何度実行しても安全。
- **`~` を汚さない**: すべて XDG 仕様に従い `~/.config`・`~/.local`・`~/.cache` 配下に配置。
- **link_map.yaml が SSOT**: 新しい設定ファイルを追加する場合はここにエントリを 1 行追加するだけ。スクリプトは触らない。
- **自動化で `rm` しない**: 削除は手動。スクリプトは作成・リンク・バックアップのみ行う。
- **curl/wget/sudo/rm 禁止**: ファイル削除・ネットワーク取得・特権操作は settings.json でブロックされている（make コマンド経由のスクリプトは除く）。

## 実装上の制約

- **Bash + Makefile**: すべてのスクリプトは Bash で書かれ、Makefile がタスクランナーとして機能する。
- **gitブランチ**: すべての作業はfeatureブランチで行い、プルリクエストを作成すること。

## タスク管理

作業記録は `tasks/` ディレクトリに作成する:
- `tasks/todo.md` — 作業チェックリスト
- `tasks/lessons.md` — 作業後の教訓・改善点
