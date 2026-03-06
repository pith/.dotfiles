.PHONY: help install install-hooks lint format

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-18s %s\n", $$1, $$2}'

install: ## Install dotfiles (runs setup.sh)
	./setup.sh

install-hooks: ## Install pre-commit hooks
	pre-commit install

lint: ## Lint all files via pre-commit
	pre-commit run --all-files

format: ## Format Lua files with stylua
	stylua nvim/.config/nvim/ wezterm/
