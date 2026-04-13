.PHONY: help bootstrap sync lint format

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-18s %s\n", $$1, $$2}'

bootstrap: ## Provision a new machine (run once)
	./bootstrap.sh

sync: ## Pull latest and re-apply dotfiles
	./sync.sh

lint: ## Lint all files via pre-commit
	pre-commit run --all-files

format: ## Format Lua files with stylua
	stylua nvim/.config/nvim/ wezterm/
