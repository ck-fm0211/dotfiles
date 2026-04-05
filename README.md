# dotfiles

[![macOS CI](https://github.com/ck-fm0211/dotfiles/actions/workflows/macos.yaml/badge.svg)](https://github.com/ck-fm0211/dotfiles/actions/workflows/macos.yaml)

Macの環境構築および設定ファイル（dotfiles）を管理するリポジトリです。

## 目次

- [必要な環境](#必要な環境)
- [クイックスタート](#クイックスタート)
- [ディレクトリ構成](#ディレクトリ構成)
- [利用可能なコマンド](#利用可能なコマンド-makefile)
- [含まれる設定](#含まれる設定)
- [トラブルシューティング](#トラブルシューティング)

## 必要な環境

- macOS 13 (Ventura) 以上（Apple Silicon / Intel 両対応）
- インターネット接続

> Xcode Command Line Tools は bootstrap.sh が自動インストールします。

## クイックスタート

### 新規 Mac の場合（ゼロから）

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ck-fm0211/dotfiles/main/scripts/bootstrap.sh)"
```

このコマンド一発で以下をすべて自動実行します:
1. macOS バージョン確認
2. Xcode Command Line Tools インストール
3. dotfiles リポジトリを `~/dotfiles` に clone
4. `make setup` 実行（Homebrew・シンボリックリンク・パッケージ・macOS 設定・クラウドツール）

### 既存環境への適用

```bash
git clone https://github.com/ck-fm0211/dotfiles.git ~/dotfiles
cd ~/dotfiles
make setup
```

### 個別にセットアップしたい場合

```bash
make help  # 利用可能なコマンドを一覧表示
```

## ディレクトリ構成

```
dotfiles/
├── .config/
│   ├── claude/          # Claude Code 設定・CLAUDE.md
│   ├── git/             # Git 設定・グローバル gitignore
│   ├── homebrew/        # Brewfile（brew / cask / mas / taps / vscode）
│   ├── iterm2/          # iTerm2 設定
│   ├── mise/            # mise ツールバージョン管理
│   ├── python/          # Python REPL 設定（XDG 準拠ヒストリ）
│   ├── sheldon/         # Zsh プラグイン設定
│   ├── vscode/          # VSCode settings.json・keybindings.json
│   ├── zsh/             # Zsh 設定ファイル群
│   │   ├── .zshenv      # 環境変数（対話・非対話の両方で読み込まれる）
│   │   ├── .zshrc       # メイン設定（sheldon・gcloud・iTerm2 連携）
│   │   ├── path.zsh     # PATH 管理を一元化
│   │   ├── settings.zsh # Zsh オプション設定
│   │   ├── completion.zsh # 補完スタイル設定
│   │   ├── alias.zsh    # エイリアス定義
│   │   ├── functions.zsh # カスタム関数
│   │   ├── bindkey.zsh  # キーバインド設定
│   │   └── .p10k.zsh    # Powerlevel10k テーマ設定
│   └── link_map.yaml    # シンボリックリンク定義（唯一の真実の源）
├── .github/
│   └── workflows/
│       └── macos.yaml   # GitHub Actions CI（shellcheck + セットアップテスト）
├── .local/
│   └── bin/scripts/     # カスタムスクリプト（PATH が通っている）
│       ├── compare_gcp_roles.sh  # GCP ロール比較ツール
│       └── my_help.sh           # スクリプトヘルプ集約
├── scripts/             # セットアップスクリプト
│   ├── bootstrap.sh     # ★ 新規 Mac を一発セットアップ
│   ├── install.sh       # Homebrew・XDG・yq インストール
│   ├── link.sh          # シンボリックリンク作成（--dry-run 対応）
│   ├── unlink.sh        # シンボリックリンク削除（ロールバック）
│   ├── backup.sh        # link.sh 実行前バックアップ
│   ├── doctor.sh        # 環境診断
│   ├── sheldon.sh       # sheldon 初期化
│   ├── mac_defaults.sh  # macOS システム設定適用
│   ├── brew_dumps.sh    # Brewfile エクスポート
│   ├── install_awscli.sh / uninstall_awscli.sh
│   ├── install_gcloud.sh / uninstall_gcloud.sh
│   └── install_claude_code.sh / uninstall_claude_code.sh
├── .editorconfig        # エディタ共通設定（インデント・改行コード等）
└── Makefile             # コマンドハブ（make help で一覧）
```

## 利用可能なコマンド (Makefile)

`make help` で最新のコマンド一覧が確認できます。

### セットアップ

| コマンド | 説明 |
|---|---|
| `make setup` | フルセットアップを一括実行 |
| `make bootstrap` | 新規 Mac 用ワンコマンドセットアップ |
| `make install` | Homebrew・Rosetta・XDG ディレクトリ・yq をインストール |
| `make link` | `link_map.yaml` に従いシンボリックリンクを作成 |
| `make link-dry` | シンボリックリンク作成のプレビュー（変更なし） |
| `make unlink` | 管理対象のシンボリックリンクをすべて削除 |
| `make backup` | link.sh 実行前に既存ファイルをバックアップ |
| `make mac-defaults` | macOS システム設定を適用 |
| `make sheldon` | Zsh プラグインマネージャーを初期化 |

### Homebrew

| コマンド | 説明 |
|---|---|
| `make brew-bundle` | CLI パッケージをインストール |
| `make brew-bundle-cask` | デスクトップアプリをインストール |
| `make brew-bundle-mas` | App Store アプリをインストール |
| `make brew-bundle-taps` | サードパーティ tap を追加 |
| `make brew-bundle-vscode` | VSCode 拡張機能をインストール |
| `make brew-dump` | 現在の状態を Brewfile にエクスポート |
| `make update` | Homebrew・sheldon・mise をまとめてアップデート |

### 外部ツール

| コマンド | 説明 |
|---|---|
| `make install-awscli` / `make uninstall-awscli` | AWS CLI v2 の管理 |
| `make install-gcloud` / `make uninstall-gcloud` | Google Cloud SDK の管理 |
| `make install-claude-code` / `make uninstall-claude-code` | Claude Code の管理 |

### 診断・検証

| コマンド | 説明 |
|---|---|
| `make doctor` | 環境の健全性チェック（シンボリックリンク・コマンド・パッケージを検査） |
| `make shellcheck` | シェルスクリプト・Zsh 設定の構文チェック |

## 含まれる設定

### Zsh 構成

| ファイル | 役割 |
|---|---|
| `.zshenv` | XDG・AWS・Docker 等の環境変数（最初に読み込まれる） |
| `path.zsh` | PATH を一元管理（Homebrew・mise・Go・Python） |
| `settings.zsh` | Zsh オプション（ヒストリ・auto_cd・補完等） |
| `completion.zsh` | 補完スタイル（グループ表示・カラー・カーソル選択等） |
| `alias.zsh` | eza・bat・gsed 等のモダン代替ツールへのエイリアス |
| `functions.zsh` | `mkcd`・`extract`・`fcd`・`gitignore`・`cdf` 等 |
| `bindkey.zsh` | Ctrl+r ヒストリ検索・Ctrl+b ブランチ選択・単語移動等 |

### 主な CLI ツール (Brewfile)

| ツール | 説明 |
|---|---|
| `bat` | `cat` の代替（シンタックスハイライト） |
| `eza` | `ls` の代替（Git 連携・カラー・ツリー表示） |
| `fd` | `find` の代替（高速・直感的） |
| `ripgrep` | `grep` の代替（高速全文検索） |
| `fzf` | ファジーファインダー |
| `gh` | GitHub CLI |
| `jq` / `yq` | JSON / YAML パーサー |
| `tldr` | シンプルな man ページ |
| `mise` | ランタイムバージョンマネージャー（Node・Python・Go・Terraform） |
| `sheldon` | Zsh プラグインマネージャー |

### mise ツールバージョン管理 (.config/mise/config.toml)

- **Node.js**: LTS を常に使用
- **Python**: 最新安定版
- **Go**: 最新安定版
- **Terraform**: 最新安定版

プロジェクトルートに `.mise.toml` を置くことでバージョンをオーバーライドできます。

## トラブルシューティング

### セットアップ前に環境を確認したい

```bash
make doctor
```

PASS / WARN / FAIL 形式で現在の環境状態を診断します。

### シンボリックリンクを確認したい

```bash
make link-dry  # 作成されるリンクをプレビュー
ls -la ~/.config/zsh/
```

### セットアップ前に既存ファイルをバックアップしたい

```bash
make backup
make link
```

バックアップは `~/.dotfiles-backup/YYYYMMDD_HHMMSS/` に保存されます。

### シンボリックリンクを元に戻したい

```bash
make unlink                 # シンボリックリンクをすべて削除
make unlink -- --restore    # バックアップから元ファイルを復元
```

### Homebrew パッケージのインストール確認

```bash
brew bundle check --file=./.config/homebrew/Brewfile
```

### sheldon が動かない

```bash
make sheldon
exec zsh
```

### macOS 設定が反映されない

一部の設定は OS の再起動が必要です。

```bash
sudo shutdown -r now
```

### mise でツールが見つからない

```bash
mise install  # config.toml に記載のツールをインストール
mise doctor   # mise の診断
```
