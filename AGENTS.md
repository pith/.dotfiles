# AGENTS.md

AI agent instructions for working with this dotfiles repository.

## Repository Overview

This repository contains personal macOS dotfiles managed with GNU stow for automatic symlinking. It includes configurations for aerospace (window manager), brew (package manager), git, nvim, vim, wezterm (terminal), zsh (shell), and starship (prompt). The primary setup mechanism is `setup.sh`, which installs Homebrew, installs dependencies from `.Brewfile`, and creates symlinks via stow.

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
│   ├── .gitconfig        # Git configuration
│   └── .gitignore_global # Global git ignore patterns
├── nvim/
│   └── .config/nvim/     # Neovim configuration
├── starship/
│   └── .config/starship/ # Starship prompt config
├── vim/
│   └── .vimrc            # Vim configuration
├── wezterm/
│   └── .wezterm.lua      # WezTerm terminal config
├── zsh/
│   ├── .zshrc            # Main zsh config (sources zsh-config/*.zsh)
│   └── .zprofile         # Zsh profile
└── zsh-config/           # Modular zsh configs (NOT stowed)
    ├── 01_path.zsh       # PATH configuration
    ├── 02_alias.zsh      # Shell aliases
    ├── 02_autocompletion.zsh
    ├── 02_prompt.zsh     # Prompt setup
    ├── 03_docker.zsh     # Docker-specific config
    ├── 03_fzf.zsh        # FZF fuzzy finder config
    ├── 03_node.zsh       # Node.js setup (fnm)
    └── 03_rust.zsh       # Rust toolchain config
```

**Key Conventions:**
- Each tool has its own directory at repo root
- Stow expects the same structure as $HOME (e.g., `zsh/.zshrc` → `~/.zshrc`)
- Files starting with `.` are dotfiles that get symlinked
- `zsh-config/` is separate and sourced by `.zshrc` (not managed by stow)
- Numbered prefixes in `zsh-config/` control load order

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
- `zsh/.zshrc` sources `~/zsh-config/*.zsh` (absolute path dependency)
- FZF config requires `brew install fzf`
- Starship prompt requires `brew install starship` + init in `.zshrc`
- Powerlevel10k is in Brewfile but may conflict with starship
- Git delta requires `brew install git-delta` + config in `.gitconfig`
- Node tools require `fnm` (in Brewfile)
- Rust tools require rust toolchain (configured in `03_rust.zsh`)

**Zsh plugin chain:**
```
.zshrc → sources zsh-config/*.zsh (numbered load order)
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

### Testing Approach

```bash
# Test brew changes
brew bundle check --file ./brew/.Brewfile

# Test stow without applying
stow -n -v <package>

# Test zsh config in isolation
zsh -c 'source ~/zsh-config/02_alias.zsh && alias'

# Full integration test
./setup.sh  # Only on fresh system or VM!
```

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
vim zsh-config/01_path.zsh

# For aliases
vim zsh-config/02_alias.zsh

# For tool-specific config (e.g., docker, fzf, node)
vim zsh-config/03_<toolname>.zsh

# Test
source ~/.zshrc
```

## Critical Constraints

- **DON'T break symlinks** - Never `mv` or `rm` files in $HOME; edit in repo
- **DON'T commit secrets** - Check for API keys, tokens in configs
- **DON'T hardcode paths** - Use `$HOME`, `$(brew --prefix)`, relative paths
- **DON'T break idempotency** - `setup.sh` must be safe to run multiple times
- **PRESERVE user-specific files** - `zsh-config/secret_*.zsh` should stay local
- **VERIFY stow structure** - Files must mirror $HOME layout exactly
- **TEST before commit** - Use `stow -n` to verify changes won't break symlinks
- **RESPECT load order** - Numbered prefixes in `zsh-config/` are significant

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
