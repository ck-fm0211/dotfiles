.PHONY: help
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: install link brew-bundle-taps brew-bundle brew-bundle-cask brew-bundle-vscode sheldon mac-defaults install-awscli install-gcloud install-claude-code ## Run full setup (install, link, brew, sheldon, mac-defaults, cloud tools)

.PHONY: shellcheck
shellcheck: ## Run shellcheck on all shell scripts
	shellcheck ./**/*.sh ./.config/zsh/.zshrc ./.config/zsh/.zshenv ./.local/**/**/*.sh

.PHONY: install
install: ## Install Homebrew, Rosetta, XDG directories, and yq
	./scripts/install.sh

.PHONY: link
link: ## Create symlinks based on .config/link_map.yaml
	./scripts/link.sh

.PHONY: sheldon
sheldon: ## Initialize sheldon zsh plugin manager
	./scripts/sheldon.sh

.PHONY: mac-defaults
mac-defaults: ## Apply macOS system preferences
	./scripts/mac_defaults.sh

.PHONY: install-awscli
install-awscli: ## Install AWS CLI v2
	./scripts/install_awscli.sh

.PHONY: install-gcloud
install-gcloud: ## Install Google Cloud SDK
	./scripts/install_gcloud.sh

.PHONY: uninstall-awscli
uninstall-awscli: ## Uninstall AWS CLI v2
	./scripts/uninstall_awscli.sh

.PHONY: uninstall-gcloud
uninstall-gcloud: ## Uninstall Google Cloud SDK
	./scripts/uninstall_gcloud.sh

.PHONY: brew-bundle
brew-bundle: ## Install packages from Brewfile
	brew bundle --file=./.config/homebrew/Brewfile

.PHONY: brew-bundle-mas
brew-bundle-mas: ## Install Mac App Store apps from Brewfile.mas
	brew bundle --file=./.config/homebrew/Brewfile.mas

.PHONY: brew-bundle-cask
brew-bundle-cask: ## Install cask apps from Brewfile.cask
	brew bundle --file=./.config/homebrew/Brewfile.cask

.PHONY: brew-bundle-taps
brew-bundle-taps: ## Add Homebrew taps from Brewfile.taps
	brew bundle --file=./.config/homebrew/Brewfile.taps

.PHONY: brew-bundle-vscode
brew-bundle-vscode: ## Install VSCode extensions from Brewfile.vscode
	brew bundle --file=./.config/homebrew/Brewfile.vscode

.PHONY: brew-dump
brew-dump: ## Dump current Homebrew state to Brewfiles
	./scripts/brew_dumps.sh

.PHONY: install-claude-code
install-claude-code: ## Install Claude Code (Anthropic CLI)
	./scripts/install_claude_code.sh

.PHONY: uninstall-claude-code
uninstall-claude-code: ## Uninstall Claude Code
	./scripts/uninstall_claude_code.sh
