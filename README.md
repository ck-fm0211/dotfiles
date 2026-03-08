# dotfiles

Macの環境構築および設定ファイル（dotfiles）を管理するリポジトリです。

## セットアップ

以下のコマンドを実行することで、基本的な環境構築を一括で行うことができます。

```bash
make setup

```

このコマンドは、各種ツールのインストール、シンボリックリンクの作成、Homebrewパッケージのインストール、macOSのシステム設定などを順次実行します。

## 利用可能なコマンド (Makefile)

`make` コマンドを使用して、個別のセットアップや操作を実行できます。

### 基本セットアップ

* `make install`: Homebrewのインストール、Rosettaのインストール、XDG基本ディレクトリの作成、および `yq` のインストールを行います。
* `make link`: `.config/link_map.yaml` の設定に従い、設定ファイルのシンボリックリンクを作成します。
* `make mac-defaults`: macOSの各種システム設定（隠しファイルの表示、Dockの設定、トラックパッドの速度調整など）を適用します。
* `make sheldon`: Zshのプラグインマネージャーである `sheldon` の初期化を行います。

### Homebrew 関連

* `make brew-bundle`: `Brewfile` に記載されたパッケージをインストールします。
* `make brew-bundle-mas` / `cask` / `taps` / `vscode` : それぞれ個別のBrewfileからインストールを実行します。
* `make brew-dump`: 現在インストールされているHomebrewパッケージのリストを各 `Brewfile` に書き出してバックアップします。

  ### 外部ツール・SDKの管理

* `make install-awscli` / `make uninstall-awscli`: AWS CLI v2 のインストールおよびアンインストールを行います。
* `make install-gcloud` / `make uninstall-gcloud`: Google Cloud SDK のインストールおよびアンインストールを行います。
* `make install-claude-code`: Claude Code (Anthropic CLI) のインストールを行います。インストール後、`claude` コマンドで認証を行ってください。

### 開発・検証用

* `make shellcheck`: リポジトリ内のシェルスクリプトやzshの設定ファイルに対して `shellcheck` を実行し、構文チェックを行います。

## 手動でのバックアップ

Homebrewの現在の状態を手動でバックアップしたい場合は、以下のコマンドを実行してください。

```bash
brew bundle dump --global --force

```
