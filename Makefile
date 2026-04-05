.PHONY: setup
setup: install link brew-bundle brew-bundle-mas brew-bundle-cask brew-bundle-taps brew-bundle-vscode sheldon mac-defaults install_awscli install_gcloud

.PHONY: shellcheck
shellcheck:
	shellcheck ./**/*.sh ./.config/zsh/.zshrc ./.config/zsh/.zshenv ./.local/**/**/*.sh

.PHONY: install
install:
	./scripts/install.sh

.PHONY: link
link:
	./scripts/link.sh

.PHONY: sheldon
sheldon:
	./scripts/sheldon.sh

.PHONY: mac
mac-defaults:
	./scripts/mac_defaults.sh

.PHONY: install_awscli
install-awscli:
	./scripts/install_awscli.sh

.PHONY: install_gcloud
install-gcloud:
	./scripts/install_gcloud.sh

.PHONY: uninstall_awscli
uninstall-awscli:
	./scripts/uninstall_awscli.sh

.PHONY: uninstall_gcloud
uninstall-gcloud:
	./scripts/uninstall_gcloud.sh

.PHONY: brew-bundle
brew-bundle:
	brew bundle --file=./.config/homebrew/Brewfile

.PHONY: brew-bundle-mas
brew-bundle-mas:
	brew bundle --file=./.config/homebrew/Brewfile.mas

.PHONY: brew-bundle-cask
brew-bundle-cask:
	brew bundle --file=./.config/homebrew/Brewfile.cask

.PHONY: brew-bundle-taps
brew-bundle-taps:
	brew bundle --file=./.config/homebrew/Brewfile.taps

.PHONY: brew-bundle-vscode
brew-bundle-vscode:
	brew bundle --file=./.config/homebrew/Brewfile.vscode

.PHONY: brew-dump
brew-dump:
	./scripts/brew_dumps.sh
