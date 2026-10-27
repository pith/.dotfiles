# AGENTS.md

AI agent instructions for working with this dotfiles repository.

## Repository Overview

Personal macOS dotfiles managed with GNU stow: each top-level dir is a package mirroring `$HOME`. `bootstrap.sh` provisions a new machine once (Homebrew, brew bundle, stow, git identity); `sync.sh` runs after every git pull (pull, brew update, restow, plugin updates). Both source `lib.zsh`, the single source of truth for `STOW_PACKAGES` and `HERDR_PLUGINS`.

## Checks

No test suite; validate manually. `make lint` runs pre-commit on all files (zsh syntax, stylua, TOML, `herdr config check`); `make help` lists the other targets. Dry-run stow before applying: `stow -n -v <package>`.

## Code Style

### Shell Scripts (Zsh)

- Shebang `#!/bin/zsh`, then `set -euo pipefail`
- Quote all variables: `"$var"`
- Globals `SCREAMING_SNAKE_CASE`, locals `lowercase_with_underscores`, functions `lowercase_with_underscores()`, aliases short lowercase (`gst`)
- Errors go to stderr with a non-zero exit
- Script header with usage; section headers `#### Section Name ####`

Zsh config naming and load order live in `zsh/.config/zsh/CLAUDE.md`. Lua formatting is enforced by `stylua.toml` + pre-commit.

## Theme

**All tools use Catppuccin Mocha.** When adding a new tool config, always check https://github.com/catppuccin/catppuccin for an official port and apply it before committing — see the `add-tool` skill for the palette and per-tool theme status.

## Non-obvious Dependencies

- macOS only: guard anything Linux-specific. Use `$(brew --prefix)` over hardcoded `/opt/homebrew`.
- `git/.gitconfig` includes `~/.gitconfig.local` (name, email, signingkey), created by `bootstrap.sh`; `*.local` is gitignored.
- `zsh/.zshrc` sources `~/.config/zsh/*.zsh`, then machine-local secrets in `~/.config/zsh/local/*.zsh`.
- Node and other runtimes come from `mise`: activated in `03_mise.zsh` (interactive) and `.zprofile` (non-interactive shims); config in `mise/.config/mise/`.
- `sesh.toml` is gitignored (machine-local project paths), so `sesh/` has no tracked files; `create_sesh_config` in `lib.zsh` seeds it before stowing. sesh and herdr-plugin-sesh both read it.
- herdr writes its socket, plugins and session state into `~/.config/herdr`, which must stay a real directory with only `config.toml` symlinked (`prepare_stow_targets` in `lib.zsh`). Plugin wiring is commented in `herdr/.config/herdr/config.toml`.

## Critical Constraints

- **Edit in the repo, never in `$HOME`**: changes are live through the symlinks. Never `mv` or `rm` files in `$HOME`.
- **DON'T commit secrets** - Check for API keys, tokens in configs
- **DON'T hardcode paths** - Use `$HOME`, `$(brew --prefix)`, relative paths
- **DON'T break idempotency** - `bootstrap.sh` and `sync.sh` must be safe to run multiple times
- **PRESERVE user-specific files** - `zsh/.config/zsh/local/` is for machine-local secrets
- **VERIFY stow structure** - Files must mirror $HOME layout exactly; `stow -n` before committing
- **RESPECT load order** - Numbered prefixes in `zsh/.config/zsh/` are significant

## Quick Reference

```bash
# Bootstrap new system (run once)
./bootstrap.sh

# Sync with remote (run after git pull)
./sync.sh

# Capture existing dotfile
./capture.sh <source_path> <config_name>

# Re-apply all symlinks (package list lives in lib.zsh)
zsh -c 'source lib.zsh && prepare_stow_targets && stow -R "${STOW_PACKAGES[@]}"'

# Remove symlinks
stow -D <package_name>

# Reload shell
exec zsh -l
```
