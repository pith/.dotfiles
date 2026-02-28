# AGENTS.md

AI agent instructions for working with this dotfiles repository.

## Repository Overview

This repository contains personal macOS dotfiles managed with GNU stow for automatic symlinking. It includes configurations for aerospace (window manager), brew (package manager), git, nvim, vim, wezterm (terminal), zsh (shell), and starship (prompt). The primary setup mechanism is `setup.sh`, which installs Homebrew, installs dependencies from `.Brewfile`, and creates symlinks via stow.

## Build, Lint, and Test Commands

**No formal test suite exists.** Manual testing is the primary validation method.

### Linting

```bash
# Lint shell scripts (if shellcheck installed)
shellcheck setup.sh capture.sh zsh/.config/zsh/*.zsh

# Format shell scripts (if shfmt installed)
shfmt -w -i 2 setup.sh capture.sh

# Format Lua files (Neovim configs)
cd nvim/.config/nvim && stylua . --config-path stylua.toml

# Validate Brewfile syntax
brew bundle check --file ./brew/.Brewfile
```

### Testing

```bash
# Test stow operations (dry run - safe)
stow -n -v <package_name>

# Test shell config in isolated session
zsh -c 'source ~/.config/zsh/02_alias.zsh && alias'

# Test individual zsh config file
zsh -c 'source ~/.config/zsh/03_fzf.zsh && echo "Loaded successfully"'

# Full integration test (use with caution)
./setup.sh  # Only safe on fresh system or VM

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

**Style:**
- 2-space indentation (enforced by stylua)
- 120 character line width
- Use `local` for all variables
- Single-line comments: `--`
- Return config objects

**Example:**
```lua
local config = require("module")

local settings = {
  key = "value",
  nested = {
    inner = "value"
  }
}

return settings
```

### TOML (AeroSpace, Starship)

- Use kebab-case for keys: `start-at-login`
- Inline comments after values for clarification
- Section comments with documentation links

### File Organization

**zsh/.config/zsh/ naming:**
- `01_*.zsh` - System configuration (PATH)
- `02_*.zsh` - Shell behavior (aliases, completion, prompt)
- `03_*.zsh` - Tool-specific configs
- `local/` - Machine-local secrets (gitignored, not in git)

## Structure & Organization

```
dotfiles/
├── setup.sh              # Main setup script (installs brew + deps, runs stow)
├── capture.sh            # Utility to capture new dotfiles into stow structure
├── brew/
│   └── .Brewfile         # Homebrew dependencies (formulae, casks, mas, vscode)
├── aerospace/
│   └── .config/aerospace/  # Window manager config
├── git/
│   ├── .gitconfig              # Git configuration (shared, no personal info)
│   ├── .gitconfig.local.example # Template for machine-specific [user] section
│   └── .gitignore_global       # Global git ignore patterns
├── nvim/
│   └── .config/nvim/     # Neovim configuration
├── starship/
│   └── .config/starship/ # Starship prompt config
├── vim/
│   └── .vimrc            # Vim configuration
├── wezterm/
│   └── .wezterm.lua      # WezTerm terminal config
└── zsh/
    ├── .zshrc            # Main zsh config (sources ~/.config/zsh/*.zsh)
    ├── .zprofile         # Zsh profile
    └── .config/zsh/      # Modular zsh configs (stow-managed, XDG-compliant)
        ├── 01_path.zsh       # PATH configuration
        ├── 02_alias.zsh      # Shell aliases
        ├── 02_autocompletion.zsh
        ├── 02_prompt.zsh     # Prompt setup
        ├── 03_docker.zsh     # Docker-specific config
        ├── 03_fzf.zsh        # FZF fuzzy finder config
        ├── 03_node.zsh       # Node.js setup (fnm)
        ├── 03_rust.zsh       # Rust toolchain config
        └── local/            # Machine-local secrets (gitignored)
            └── secret_*.zsh  # Never committed
```

**Key Conventions:**
- Each tool has its own directory at repo root
- Stow expects the same structure as $HOME (e.g., `zsh/.zshrc` → `~/.zshrc`)
- Files starting with `.` are dotfiles that get symlinked
- Zsh configs live in `zsh/.config/zsh/` (XDG-compliant, stow-managed → `~/.config/zsh/`)
- Numbered prefixes in `zsh/.config/zsh/` control load order
- Machine-local secrets go in `zsh/.config/zsh/local/` (gitignored)
- Machine-specific git config goes in `~/.gitconfig.local` (gitignored via `*.local`)

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
- Homebrew paths: `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
- Use `$(brew --prefix)` for portable brew references
- Check for macOS-specific binaries before use (e.g., `pbcopy`, `open`)

### Dependencies Between Configs

**Critical dependencies:**
- `git/.gitconfig` uses `[include] path = ~/.gitconfig.local` for personal info (name, email, signingkey)
- `~/.gitconfig.local` is created by `setup.sh` on first run (not in git, `*.local` is gitignored)
- `zsh/.zshrc` sources `~/.config/zsh/*.zsh` and `~/.config/zsh/local/*.zsh`
- FZF config requires `brew install fzf`
- Starship prompt requires `brew install starship` + init in `.zshrc`
- Powerlevel10k is in Brewfile but may conflict with starship
- Git delta requires `brew install git-delta` + config in `.gitconfig`
- Node tools require `fnm` (in Brewfile)
- Rust tools require rust toolchain (configured in `03_rust.zsh`)

**Zsh plugin chain:**
```
.zshrc → sources ~/.config/zsh/*.zsh (numbered load order)
      → sources ~/.config/zsh/local/*.zsh (secrets)
      → loads zsh-autosuggestions (brew)
      → loads zsh-syntax-highlighting (brew)
      → initializes starship prompt
```

### When to Update setup.sh vs Individual Configs

**Update `setup.sh` when:**
- Adding new tool directories to stow
- Changing install order or dependencies
- Modifying the bootstrap process

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

### Adding a New Dotfile Configuration

```bash
# Option 1: Use capture.sh (recommended)
./capture.sh ~/.config/newtool newtool

# Option 2: Manual
mkdir -p newtool/.config/newtool
cp -r ~/.config/newtool/* newtool/.config/newtool/

# Add to setup.sh stow line
# Before: stow aerospace brew git nvim starship vim wezterm zsh
# After:  stow aerospace brew git newtool nvim starship vim wezterm zsh

# Test
stow -n -v newtool
stow newtool
```

### Updating Existing Tool Configs

```bash
# Edit directly in repo
vim nvim/.config/nvim/init.lua

# Changes are live (symlinked)
# Restart tool or reload config
```

### Adding Brew Packages

```bash
# Edit Brewfile
vim brew/.Brewfile

# Add entries:
# brew "package-name"           # CLI tool
# cask "app-name"               # GUI app
# mas "App Name", id: 123456    # Mac App Store
# vscode "publisher.extension"  # VSCode extension

# Install
brew bundle --file ./brew/.Brewfile

# Cleanup removed packages (optional)
brew bundle cleanup --file ./brew/.Brewfile
```

### Modifying Shell Setup

```bash
# For PATH changes
vim zsh/.config/zsh/01_path.zsh

# For aliases
vim zsh/.config/zsh/02_alias.zsh

# For tool-specific config (e.g., docker, fzf, node)
vim zsh/.config/zsh/03_<toolname>.zsh

# Test
source ~/.zshrc
```

## Critical Constraints

- **DON'T break symlinks** - Never `mv` or `rm` files in $HOME; edit in repo
- **DON'T commit secrets** - Check for API keys, tokens in configs
- **DON'T hardcode paths** - Use `$HOME`, `$(brew --prefix)`, relative paths
- **DON'T break idempotency** - `setup.sh` must be safe to run multiple times
- **PRESERVE user-specific files** - `zsh/.config/zsh/local/` is for machine-local secrets
- **VERIFY stow structure** - Files must mirror $HOME layout exactly
- **TEST before commit** - Use `stow -n` to verify changes won't break symlinks
- **RESPECT load order** - Numbered prefixes in `zsh/.config/zsh/` are significant

## Quick Reference

```bash
# Bootstrap new system
./setup.sh

# Capture existing dotfile
./capture.sh <source_path> <config_name>

# Re-apply all symlinks
stow -R aerospace brew git nvim starship vim wezterm zsh

# Remove symlinks
stow -D <package_name>

# Update brew packages
brew bundle --file ./brew/.Brewfile

# Reload shell
exec zsh -l
```
