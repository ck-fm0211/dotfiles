setup: install link brew sheldon mac-defaults install_awscli install_gcloud

install:
	./scripts/install.sh

link:
	./scripts/link.sh

sheldon:
	./scripts/sheldon.sh

brew:
	./scripts/brew.sh

mac-defaults:
	./scripts/mac_defaults.sh

install_awscli:
	./scripts/install_awscli.sh

install_gcloud:
	./scripts/install_gcloud.sh

uninstall_awscli:
	./scripts/uninstall_awscli.sh

uninstall_gcloud:
	./scripts/uninstall_gcloud.sh
