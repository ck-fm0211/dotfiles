.DEFAULT_GOAL := help

.PHONY: help
help: ## コマンド一覧を表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

# ============================================================
# セットアップ
# ============================================================

.PHONY: setup
setup: install brew-bundle-taps brew-bundle brew-bundle-cask brew-bundle-vscode sheldon link mise-install mac-defaults git-hooks install-awscli install-gcloud install-claude-code mcp-setup ## フルセットアップを一括実行

.PHONY: bootstrap
bootstrap: ## 新規 Mac で make を使わずに一発セットアップ（install.sh → link.sh → make setup の順に実行）
	./scripts/bootstrap.sh

.PHONY: install
install: ## Homebrew・Rosetta・XDG ディレクトリ・yq をインストール
	./scripts/install.sh

.PHONY: link
link: ## link_map.yaml に従いシンボリックリンクを作成
	./scripts/link.sh

.PHONY: link-dry
link-dry: ## シンボリックリンク作成のプレビュー（実際には変更しない）
	./scripts/link.sh --dry-run

.PHONY: unlink
unlink: ## link.sh が作成したシンボリックリンクをすべて削除
	./scripts/unlink.sh

.PHONY: backup
backup: ## link.sh が上書きするファイルを事前にバックアップ（~/.dotfiles-backup/）
	./scripts/backup.sh

.PHONY: sheldon
sheldon: ## sheldon（Zsh プラグインマネージャー）を初期化
	./scripts/sheldon.sh

.PHONY: mise-install
mise-install: ## mise で管理するツール（node・python・go・terraform）をインストール
	@echo ">>> Node.js GPG 署名検証キーをインポートしています..."
	@# Node.js リリースチームのキーを openpgp.org から取得（失敗時は ubuntu keyserver にフォールバック）
	@gpg --keyserver hkps://keys.openpgp.org --recv-keys \
	  C0D6248439F1D5604AAFFB4021D900FFDB233756 \
	  DD792F5973C6DE52C432CBDAC4C61782A7BFAD4 \
	  CC68F5A3106FF448322E48229BC359AF0523A306 \
	  890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
	  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
	  108F52B48DB57BB0CC439B2997B01419BD92F80A \
	  2>&1 | grep -v "keyboxd" || \
	gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys \
	  C0D6248439F1D5604AAFFB4021D900FFDB233756 \
	  DD792F5973C6DE52C432CBDAC4C61782A7BFAD4 \
	  CC68F5A3106FF448322E48229BC359AF0523A306 \
	  890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
	  C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
	  108F52B48DB57BB0CC439B2997B01419BD92F80A \
	  2>&1 | grep -v "keyboxd" || true
	@echo ">>> mise ツールをインストールしています..."
	mise install

.PHONY: mac-defaults
mac-defaults: ## macOS システム設定を適用（Finder・Dock・トラックパッドなど）
	./scripts/mac_defaults.sh

# ============================================================
# Homebrew
# ============================================================

.PHONY: brew-bundle
brew-bundle: ## Brewfile の CLI パッケージをインストール
	brew bundle --file=./.config/homebrew/Brewfile

.PHONY: brew-bundle-mas
brew-bundle-mas: ## Brewfile.mas の App Store アプリをインストール
	brew bundle --file=./.config/homebrew/Brewfile.mas

.PHONY: brew-bundle-cask
brew-bundle-cask: ## Brewfile.cask のデスクトップアプリをインストール
	brew bundle --file=./.config/homebrew/Brewfile.cask

.PHONY: brew-bundle-taps
brew-bundle-taps: ## Brewfile.taps のサードパーティ tap を追加
	brew bundle --file=./.config/homebrew/Brewfile.taps

.PHONY: brew-bundle-vscode
brew-bundle-vscode: ## Brewfile.vscode の VSCode 拡張機能をインストール
	brew bundle --file=./.config/homebrew/Brewfile.vscode

.PHONY: brew-dump
brew-dump: ## 現在のインストール済みパッケージを Brewfile に書き出す
	./scripts/brew_dumps.sh

.PHONY: update
update: ## Homebrew パッケージ・sheldon プラグイン・mise ツールをまとめてアップデート
	@echo ">>> Homebrew をアップデートしています..."
	brew update && brew upgrade && brew cleanup
	@echo ">>> sheldon プラグインをアップデートしています..."
	sheldon lock --update
	@echo ">>> mise ツールをアップデートしています..."
	mise self-update --yes 2>/dev/null || true
	mise upgrade 2>/dev/null || true
	@echo ">>> アップデート完了"

# ============================================================
# 外部ツール・SDK
# ============================================================

.PHONY: install-awscli
install-awscli: ## AWS CLI v2 をインストール
	./scripts/install_awscli.sh

.PHONY: uninstall-awscli
uninstall-awscli: ## AWS CLI v2 をアンインストール
	./scripts/uninstall_awscli.sh

.PHONY: install-gcloud
install-gcloud: ## Google Cloud SDK をインストール
	./scripts/install_gcloud.sh

.PHONY: uninstall-gcloud
uninstall-gcloud: ## Google Cloud SDK をアンインストール
	./scripts/uninstall_gcloud.sh

.PHONY: install-claude-code
install-claude-code: ## Claude Code（Anthropic CLI）をインストール
	./scripts/install_claude_code.sh

.PHONY: uninstall-claude-code
uninstall-claude-code: ## Claude Code をアンインストール
	./scripts/uninstall_claude_code.sh

.PHONY: mcp-setup
mcp-setup: ## MCPサーバーをClaude Codeにグローバル登録
	./scripts/mcp_setup.sh

# ============================================================
# 診断・メンテナンス
# ============================================================

.PHONY: doctor
doctor: ## 環境の健全性チェック（macOS バージョン・ディスク・Git・mise・シンボリックリンク等）
	./scripts/doctor.sh

.PHONY: clean
clean: ## 各種キャッシュを削除してディスク容量を解放（Homebrew・pip・npm・Go・Docker・Zsh）
	./scripts/clean.sh

.PHONY: clean-dry
clean-dry: ## クリーンアップの対象を表示するだけ（実際には削除しない）
	DRY_RUN=1 ./scripts/clean.sh

.PHONY: git-hooks
git-hooks: ## グローバル Git フック（core.hooksPath）を設定する
	git config --global core.hooksPath '~/.config/git/hooks'
	@echo "  ✓ core.hooksPath = $$(git config --global core.hooksPath)"
	@echo "  ✓ Conventional Commits フックが有効になりました"

.PHONY: shellcheck
shellcheck: ## シェルスクリプト・Zsh 設定ファイルの構文チェック
	shellcheck ./**/*.sh ./.config/zsh/.zshrc ./.config/zsh/.zshenv ./.local/**/**/*.sh
