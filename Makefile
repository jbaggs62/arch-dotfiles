.PHONY: help backup setup sync update-packages stow-all unstow-all

help: ## Show this help message
	@echo "Dotfiles Management Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

backup: ## Backup current system to dotfiles
	./scripts/backup.sh

setup: ## Setup dotfiles on new system (run with: make setup REPO=<url>)
	./scripts/setup.sh $(REPO)

sync: ## Sync changes from repository
	./scripts/sync.sh

update-packages: ## Update package lists
	./scripts/update-packages.sh

stow-all: ## Stow all packages
	@for package in shell config local; do \
		if [ -d "$$package" ]; then \
			echo "Stowing $$package..."; \
			stow "$$package"; \
		fi; \
	done

unstow-all: ## Unstow all packages
	@for package in shell config local; do \
		if [ -d "$$package" ]; then \
			echo "Unstowing $$package..."; \
			stow -D "$$package"; \
		fi; \
	done

install-stow: ## Install GNU Stow
	sudo pacman -S stow

status: ## Show git status and stow status
	@echo "=== Git Status ==="
	@git status --short || echo "Not a git repository"
	@echo ""
	@echo "=== Stowed Packages ==="
	@for package in shell config local; do \
		if [ -d "$$package" ]; then \
			echo "📦 $$package: $(shell find $$package -type f | wc -l) files"; \
		fi; \
	done