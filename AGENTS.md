# AGENTS.md

AI agent instructions for working with this dotfiles repository.

## Repository Overview

This repository contains personal macOS dotfiles managed with GNU stow for automatic symlinking; run `ls` at the repo root for the current tool list. Setup uses two scripts: `bootstrap.sh` (run once on a new machine — installs Homebrew, brew bundle, stow, git identity) and `sync.sh` (run after every git pull — pulls latest, updates brew packages, restows symlinks).

## Build, Lint, and Test Commands

**No formal test suite exists.** Manual testing is the primary validation method.

Run `make help` for the available lint/format targets (`make lint` runs pre-commit across all files, `make format` runs stylua).

### Testing

```bash
# Test stow operations (dry run - safe)
stow -n -v <package_name>

# Test shell config in isolated session
zsh -c 'source ~/.config/zsh/02_alias.zsh && alias'

# Test individual zsh config file
zsh -c 'source ~/.config/zsh/03_fzf.zsh && echo "Loaded successfully"'

# Full integration test (use with caution)
./bootstrap.sh  # Only safe on fresh system or VM

# Validate TOML configs
# AeroSpace: No CLI validator available, restart AeroSpace to test
# Starship: starship config (validates starship.toml)
starship config
```

### Manual Validation Workflow

1. Edit config files in dotfiles repo
2. If directory structure changed: `stow -R <package>`
3. Reload config: `source ~/.zshrc` or restart application
4. Test functionality manually
5. Commit if working

## Code Style Guidelines

### Shell Scripts (Zsh)

**Required:**
- Use `#!/bin/zsh` or `#!/usr/bin/env zsh` shebang
- Start scripts with `set -euo pipefail` (exit on error, undefined vars, pipe failures)
- Quote all variables: `"$VARIABLE_NAME"`
- Use uppercase for exported variables, lowercase for local

**Naming:**
- Variables: `SCREAMING_SNAKE_CASE` for globals, `lowercase_with_underscores` for locals
- Functions: `lowercase_with_underscores()`
- Aliases: Short lowercase (e.g., `gst`, `gc`)

**Error Handling:**
```bash
if [ ! -e "$PATH" ]; then
    echo "Error: Path does not exist" >&2
    exit 1
fi
```

**Comments:**
- Header with usage examples for scripts
- Inline comments for complex logic
- Section headers: `#### Section Name ####`

### Lua (Neovim, WezTerm)

Formatting is enforced mechanically by `stylua.toml` + the pre-commit hook.

### TOML (AeroSpace, Starship, Sesh)

- Use kebab-case for keys: `start-at-login`
- Inline comments after values for clarification
- Section comments with documentation links

Zsh config naming and load-order conventions live in `zsh/.config/zsh/CLAUDE.md`. Repo layout and Brewfile structure are derivable via `ls`/`find` — see `AI Agent Guidelines` below for what isn't obvious from the tree.

## Theme

**All tools use Catppuccin Mocha.** When adding a new tool config, always check https://github.com/catppuccin/catppuccin for an official port and apply it before committing — see the `add-tool` skill for the palette and per-tool theme status.

## AI Agent Guidelines

### Safe Modification Strategy

1. **Before editing any config:**
   ```bash
   # Check current symlinks
   ls -la ~/ | grep "dotfiles"

   # Verify stow structure
   stow -n -v <package_name>  # Dry run
   ```

2. **After modifications:**
   ```bash
   # Re-stow if directory structure changed
   stow -R <package_name>

   # Test in new shell session
   zsh -l  # For shell configs
   ```

3. **Never directly edit files in $HOME** - always edit in the dotfiles repo

### Platform Considerations

- **macOS only** - Don't add Linux-specific configs without conditional checks
- Homebrew paths: `/opt/homebrew` (Apple Silicon)
- Use `$(brew --prefix)` for portable brew references

### Dependencies Between Configs

**Critical dependencies:**
- `git/.gitconfig` uses `[include] path = ~/.gitconfig.local` for personal info (name, email, signingkey)
- `~/.gitconfig.local` is created by `bootstrap.sh` on first run (not in git, `*.local` is gitignored)
- `zsh/.zshrc` sources `~/.config/zsh/*.zsh` and `~/.config/zsh/local/*.zsh`
- FZF config requires `brew install fzf`
- Starship prompt requires `brew install starship` + init in `.zshrc`
- Powerlevel10k is in Brewfile but may conflict with starship
- Git delta requires `brew install git-delta` + config in `.gitconfig`
- Node (and other tools) managed by `mise` (in Brewfile.dev); activated via `03_mise.zsh` (interactive) and `.zprofile` (non-interactive/shims); global config at `mise/.config/mise/config.toml`; default npm packages at `mise/.config/mise/default-npm-packages`
- Rust tools require rust toolchain (configured in `03_rust.zsh`)
- Sesh requires `brew install sesh` + fzf + tmux; configured in `sesh/.config/sesh/sesh.toml`, keybinding in `tmux.conf`

**Zsh plugin chain:**
```
.zshrc → sources ~/.config/zsh/*.zsh (numbered load order)
      → sources ~/.config/zsh/local/*.zsh (secrets)
      → loads zsh-autosuggestions (brew)
      → loads zsh-syntax-highlighting (brew)
      → initializes starship prompt
```

### When to Update bootstrap.sh / sync.sh vs Individual Configs

**Update `bootstrap.sh` when:**
- Changing one-time provisioning steps (Homebrew install, git identity prompt)
- Adding new tool directories to the stow packages list

**Update `sync.sh` when:**
- Changing the pull-and-reconcile workflow
- Adjusting how packages or symlinks are updated on sync

**Update `brew/.Brewfile` when:**
- Adding/removing packages, casks, or Mac App Store apps
- Adding VSCode extensions
- Changing taps

**Update individual configs when:**
- Tweaking tool settings (most common)
- Adding aliases, functions, or environment variables

**Update `capture.sh` when:**
- Changing how new dotfiles are imported
- Modifying backup or symlink behavior

## Common Operations

Adding a new tool (Brewfile entry, config structure, theme, `bootstrap.sh`/`sync.sh` registration) is fully covered by the `add-tool` skill — use it instead of doing this by hand. For editing an existing config, just edit the file in the repo; the symlink makes it live immediately.

## Critical Constraints

- **DON'T break symlinks** - Never `mv` or `rm` files in $HOME; edit in repo
- **DON'T commit secrets** - Check for API keys, tokens in configs
- **DON'T hardcode paths** - Use `$HOME`, `$(brew --prefix)`, relative paths
- **DON'T break idempotency** - `bootstrap.sh` and `sync.sh` must be safe to run multiple times
- **PRESERVE user-specific files** - `zsh/.config/zsh/local/` is for machine-local secrets
- **VERIFY stow structure** - Files must mirror $HOME layout exactly
- **TEST before commit** - Use `stow -n` to verify changes won't break symlinks
- **RESPECT load order** - Numbered prefixes in `zsh/.config/zsh/` are significant

## Quick Reference

```bash
# Bootstrap new system (run once)
./bootstrap.sh

# Sync with remote (run after git pull)
./sync.sh

# Capture existing dotfile
./capture.sh <source_path> <config_name>

# Re-apply all symlinks
stow -R aerospace bat brew eza git lazygit mise nvim ripgrep sesh starship tmux vim wezterm yazi zsh

# Remove symlinks
stow -D <package_name>

# Update brew packages
brew bundle --file ./brew/.Brewfile

# Reload shell
exec zsh -l
```
