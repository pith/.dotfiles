---
name: add-tool
description: Add a new tool to the stow-based dotfiles repo — handles Brewfile, config structure, Catppuccin Mocha theme, setup.sh registration, optional zsh integration, and stow validation.
argument-hint: <tool-name>
disable-model-invocation: true
allowed-tools: Read Write Edit Bash Glob Grep
---

# Add Tool to Dotfiles

You are helping add **$ARGUMENTS** to the stow-managed dotfiles repository at `/Users/pith/dotfiles`. Work through the steps below in order. Complete each step before moving to the next, and confirm with the user if anything is ambiguous.

## Step 0 — Gather Information

Before doing anything, determine:

1. **Brew install method**: `brew "name"` (CLI) / `cask "name"` (GUI) / `mas "Name", id: 123` (App Store) / `vscode "pub.ext"` (VSCode)
2. **Config path**: Where does the tool store its config? (e.g., `~/.config/tool/`, `~/.toolrc`)
3. **Existing config?**: Does `~/.config/<tool>/` (or equivalent) already exist on this machine?
4. **Shell init needed?**: Does the tool require `eval "$(tool init zsh)"`, PATH additions, or env vars?
5. **Zsh aliases/functions?**: Any shortcuts worth adding?

If $ARGUMENTS was provided as an argument, start by researching it. Otherwise ask the user for the tool name first.

---

## Step 1 — Add to Brewfile

Choose the correct sub-Brewfile:

| File | Purpose | Examples |
|------|---------|---------|
| `brew/.Brewfile.shell` | CLI shell tools | bat, eza, fzf, ripgrep, starship, yazi, sesh |
| `brew/.Brewfile.dev` | Dev/programming tools | neovim, lazygit, gh, git-delta, mise, tmux |
| `brew/.Brewfile.desktop` | GUI apps, casks, fonts, MAS | wezterm, aerospace, Nerd Fonts, Hidden Bar |
| `brew/.Brewfile.vscode` | VSCode extensions | publisher.extension-id |
| `brew/.Brewfile.core` | Bootstrap essentials only | stow, mas — do not add here |

Add the entry with an inline comment explaining what the tool does. Match the style of existing entries (see examples in each file).

Then install:
```bash
brew bundle install --file=./brew/.Brewfile
```

---

## Step 2 — Create Config Directory Structure

The repo must mirror `$HOME` exactly. Stow symlinks `<tool>/<path>` → `~/<path>`.

**Option A — Existing config** (tool already configured on this machine):
```bash
./capture.sh ~/.config/<tool> <tool>
# OR for root dotfiles:
./capture.sh ~/.<toolrc> <tool>
```

**Option B — New config** (creating from scratch):
```bash
mkdir -p <tool>/.config/<tool>/
# Then create the config file:
# Write <tool>/.config/<tool>/config.toml (or equivalent)
```

Common patterns:
- `~/.config/tool/` → `tool/.config/tool/`
- `~/.toolrc` → `tool/.toolrc`
- `~/.config/tool.toml` → `tool/.config/tool.toml`

**Critical**: Never edit files directly in `$HOME`. Always edit in the dotfiles repo (changes are live via symlinks once stowed).

---

## Step 3 — Apply Catppuccin Mocha Theme

ALL tools in this repo use Catppuccin Mocha. This is non-negotiable.

1. Check https://github.com/catppuccin/catppuccin for an official port
2. If a port exists → apply the **Mocha** flavor exactly as documented
3. If no port exists → apply colors manually using this palette:

```
# Catppuccin Mocha palette
base      = "#1e1e2e"    # Default background
mantle    = "#181825"    # Slightly darker background
crust     = "#11111b"    # Darkest background
surface0  = "#313244"    # Selection background
surface1  = "#45475a"    # Comment / muted elements
surface2  = "#585b70"    # Inactive elements
overlay0  = "#6c7086"    # Ignored / faint text
overlay1  = "#7f849c"    # Line numbers
overlay2  = "#9399b2"    # Secondary text
subtext0  = "#a6adc8"    # Subtext
subtext1  = "#bac2de"    # Subtext (brighter)
text      = "#cdd6f4"    # Default foreground

rosewater = "#f5e0dc"
flamingo  = "#f2cdcd"
pink      = "#f5c2e7"
mauve     = "#cba6f7"    # Keywords, constants
red       = "#f38ba8"    # Errors, deletions
maroon    = "#eba0ac"
peach     = "#fab387"    # Numbers, operators
yellow    = "#f9e2af"    # Warnings
green     = "#a6e3a1"    # Additions, success
teal      = "#94e2d5"
sky       = "#89dceb"
sapphire  = "#74c7ec"
blue      = "#89b4fa"    # Functions, links
lavender  = "#b4befe"    # Variables, parameters
```

After theming, update the theme status table in `CLAUDE.md` (which is a symlink to `AGENTS.md`):
- Find the `### Current theme status` table
- Add a row: `| ToolName | ✅ brief description of how theme is applied |`

---

## Step 4 — Optional: Zsh Integration

If the tool needs shell initialization, PATH, or env vars, create a new file:

**File**: `zsh/.config/zsh/03_<toolname>.zsh`

**Template**:
```zsh
# <ToolName> configuration
# <one-line description of what this file does>

# Tool initialization (if needed)
eval "$(toolname init zsh)"

# Environment variables
export TOOL_VAR="value"

# Aliases
alias t="toolname"
alias tl="toolname list"
```

**Rules**:
- Shebang not needed (sourced, not executed)
- Use `03_` prefix (tool-specific configs)
- Quote all variables
- Guard with `command -v toolname &>/dev/null || return` if the tool may not be installed
- Use `$(brew --prefix)` for brew paths, not hardcoded `/opt/homebrew`

**If adding PATH only** → add to `zsh/.config/zsh/01_path.zsh` using the existing `add_to_path` helper pattern.

**If adding aliases only** → add to `zsh/.config/zsh/02_alias.zsh`.

---

## Step 5 — Register in setup.sh

Add the tool name to the `packages` array in `setup.sh` at line 74:

```zsh
local -a packages=(aerospace bat brew eza git lazygit mise nvim ripgrep sesh starship tmux vim wezterm yazi zsh)
```

**Keep the list alphabetically sorted.** Insert the new tool name in the correct position.

---

## Step 6 — Validate Stow

Always dry-run before applying:

```bash
# Dry-run (safe — shows what would happen)
stow -n -v <tool>

# Apply (only after dry-run succeeds)
stow <tool>

# Verify symlinks
ls -la ~/.config/<tool>
```

If conflicts are detected, investigate before using `--force`. Conflicts usually mean an existing config wasn't captured in Step 2.

---

## Step 7 — Test the Configuration

```bash
# Reload shell config if zsh integration was added
source ~/.config/zsh/03_<toolname>.zsh

# Verify brew install
brew list | grep <tool>

# Verify symlinks exist
ls -la ~/.config/<tool>/   # or equivalent path

# Launch the tool and verify it works
<toolname> --version   # or open the tool

# If config was themed, verify colors render correctly
```

---

## Step 8 — Commit

Stage only files in the dotfiles repo (never in `$HOME`):

```bash
git add <tool>/
git add brew/.Brewfile.<subfile>
git add setup.sh
git add zsh/.config/zsh/03_<toolname>.zsh  # if created
git add AGENTS.md  # if theme table was updated

git commit -m "feat(<tool>): add <tool> config"
```

Conventional commit format: `feat(<tool>): add <tool> config [with Catppuccin Mocha theme]`

---

## Quick Reference

**Critical constraints:**
- Never edit files in `$HOME` directly — always edit in the dotfiles repo
- Always run `stow -n -v` (dry-run) before `stow`
- Quote all shell variables: `"$VARIABLE"`
- Use `$(brew --prefix)` not `/opt/homebrew` for portability
- `setup.sh` must remain idempotent (safe to run multiple times)
- The `packages` array in `setup.sh` must stay alphabetically sorted
- All tools must use Catppuccin Mocha — check for official port first
