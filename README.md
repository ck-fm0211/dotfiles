# dotfiles

Macの環境構築および設定ファイル（dotfiles）を管理するリポジトリです。

## 目次

- [必要な環境](#必要な環境)
- [セットアップ](#セットアップ)
- [ディレクトリ構成](#ディレクトリ構成)
- [利用可能なコマンド](#利用可能なコマンド-makefile)
- [含まれる設定](#含まれる設定)
- [トラブルシューティング](#トラブルシューティング)

## 必要な環境

- macOS（Apple Silicon / Intel 両対応）
- Xcode Command Line Tools

```bash
xcode-select --install
```

## セットアップ

以下のコマンドを実行することで、基本的な環境構築を一括で行うことができます。

```bash
make setup
```

このコマンドは以下を順次実行します:

1. Rosetta・Homebrew・yq のインストール
2. 設定ファイルのシンボリックリンク作成
3. Homebrew パッケージ・アプリのインストール
4. sheldon（Zsh プラグインマネージャー）の初期化
5. macOS システム設定の適用
6. AWS CLI / Google Cloud SDK / Claude Code のインストール

> **注意**: Mac App Store アプリ（`Brewfile.mas`）は `make setup` に含まれません。
> `make brew-bundle-mas` で個別にインストールしてください。

## ディレクトリ構成

```
dotfiles/
├── .config/
│   ├── claude/          # Claude Code 設定
│   ├── git/             # Git 設定・グローバル gitignore
│   ├── homebrew/        # Brewfile（brew / cask / mas / vscode）
│   ├── iterm2/          # iTerm2 設定
│   ├── python/          # Python REPL 設定
│   ├── sheldon/         # Zsh プラグイン設定
│   ├── vscode/          # VSCode settings.json
│   ├── zsh/             # Zsh 設定ファイル群
│   └── link_map.yaml    # シンボリックリンク定義
├── .github/
│   └── workflows/       # GitHub Actions CI
├── .local/
│   └── bin/scripts/     # カスタムスクリプト
├── scripts/             # セットアップスクリプト
└── Makefile
```

## 利用可能なコマンド (Makefile)

`make` コマンドを使用して、個別のセットアップや操作を実行できます。
一覧は `make help` で確認できます。

### 基本セットアップ

| コマンド | 説明 |
|---|---|
| `make setup` | フルセットアップを一括実行 |
| `make install` | Homebrew・Rosetta・XDG ディレクトリ・yq をインストール |
| `make link` | `link_map.yaml` に従いシンボリックリンクを作成 |
| `make mac-defaults` | macOS システム設定を適用（Finder・Dock・トラックパッドなど） |
| `make sheldon` | Zsh プラグインマネージャー sheldon を初期化 |

### Homebrew 関連

| コマンド | 説明 |
|---|---|
| `make brew-bundle` | `Brewfile` の CLI パッケージをインストール |
| `make brew-bundle-cask` | `Brewfile.cask` のデスクトップアプリをインストール |
| `make brew-bundle-mas` | `Brewfile.mas` の App Store アプリをインストール |
| `make brew-bundle-taps` | `Brewfile.taps` のサードパーティ tap を追加 |
| `make brew-bundle-vscode` | `Brewfile.vscode` の VSCode 拡張機能をインストール |
| `make brew-dump` | 現在のインストール済みパッケージを Brewfile にバックアップ |

### 外部ツール・SDK の管理

| コマンド | 説明 |
|---|---|
| `make install-awscli` | AWS CLI v2 をインストール |
| `make uninstall-awscli` | AWS CLI v2 をアンインストール |
| `make install-gcloud` | Google Cloud SDK をインストール |
| `make uninstall-gcloud` | Google Cloud SDK をアンインストール |
| `make install-claude-code` | Claude Code (Anthropic CLI) をインストール |
| `make uninstall-claude-code` | Claude Code をアンインストール |

### 開発・検証用

| コマンド | 説明 |
|---|---|
| `make shellcheck` | シェルスクリプト・Zsh 設定ファイルの構文チェック |

## 含まれる設定

### Zsh

- **プロンプト**: Powerlevel10k（Nerd Font 対応のリッチなプロンプト）
- **プラグイン**: zsh-autosuggestions / zsh-syntax-highlighting / zsh-completions
- **プラグインマネージャー**: sheldon（lazy load 対応）
- **ファジーファインダー**: anyframe（Ctrl+r でヒストリ検索、Ctrl+b でブランチ checkout）

### 主な CLI ツール（Brewfile）

| ツール | 説明 |
|---|---|
| bat | `cat` の代替（シンタックスハイライト付き） |
| eza | `ls` の代替（Git 連携・カラー表示） |
| jq / yq | JSON / YAML パーサー |
| peco | インタラクティブフィルター |
| mise | ランタイムバージョンマネージャー |
| sheldon | Zsh プラグインマネージャー |

### VSCode 拡張機能（Brewfile.vscode）

Python・Terraform・Docker・SQL・TypeScript などの言語サポートと GitHub Copilot を含む 45+ 拡張機能。

## トラブルシューティング

### `make install` が失敗する

Xcode Command Line Tools が未インストールの場合があります。

```bash
xcode-select --install
```

### シンボリックリンクの確認

```bash
ls -la ~/.config/git/
ls -la ~/.config/zsh/
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

### macOS 設定を適用後に反映されない

一部の設定は OS の再起動が必要です。

```bash
sudo shutdown -r now
```
