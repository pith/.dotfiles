# 🎯 Comprehensive Improvement Plan

Here's a structured roadmap for improving this dotfiles repository:

- ✅ XDG Base Directory structure for zsh configs
- ✅ Template-based personal info management
- ✅ Full CI/CD + pre-commit hooks for validation
- ✅ Maximum shell safety with shellcheck compliance
- ✅ Custom framework with improvements (no external deps like chezmoi)
- ✅ Split Brewfiles with post-install verification
- ✅ Incremental & safe implementation strategy

---
# 📊 Implementation Roadmap (10 Phases)

## Phase 1: Architecture Fix - XDG Compliance ⚠️ BREAKING CHANGE
**Impact:** High | Complexity: Medium | Risk: Medium

**Changes:**
BEFORE:
```
dotfiles/
├── zsh/.zshrc (sources ~/dotfiles/zsh-config/*.zsh)
└── zsh-config/
    ├── 01_path.zsh
    ├── 02_alias.zsh
    └── 03_*.zsh
```

**AFTER:**
```
dotfiles/
└── zsh/
    ├── .zshrc (sources ~/.config/zsh/*.zsh)
    └── .config/zsh/
        ├── 01_path.zsh
        ├── 02_alias.zsh
        └── 03_*.zsh
```

**Files to modify:**
1. Move zsh-config/ → zsh/.config/zsh/
2. Update .zshrc to source from ~/.config/zsh/*.zsh
3. Add migration note in README
4. Update AGENTS.md with new structure

**Testing:**
```
# Backup current setup
cp ~/.zshrc ~/.zshrc.backup

# Test stow with new structure
stow -n -v zsh  # Dry run

# Verify shell loads correctly
zsh -c 'source ~/.zshrc && echo "OK"'
```

**Rollback plan:** Keep backup of old structure until verified working
---
## Phase 2: Template System for Personal Info 🔒 SECURITY
**Impact:** High | Complexity: Low | Risk: Low

**Changes:**
Create `.gitconfig.template:`
```toml
[user]
    name = __GIT_USER_NAME__
    email = __GIT_USER_EMAIL__
[core]
    editor = nvim
    excludesfile = ~/.gitignore_global
    pager = delta
[include]
    path = ~/.gitconfig.local
```

Create `git/.gitconfig.local.example:`
```toml
# Copy this to ~/.gitconfig.local and customize
[user]
    name = Your Name
    email = your.email@example.com
# Add machine-specific overrides here
```

Update `setup.sh`:
```sh
# Template substitution section
setup_git_config() {
    if [ ! -f "$HOME/.gitconfig.local" ]; then
        echo "Setting up git config..."
        read -p "Enter your name: " git_name
        read -p "Enter your email: " git_email
        
        cat > "$HOME/.gitconfig.local" << EOF
[user]
    name = $git_name
    email = $git_email
EOF
    fi
}
```

Update `.gitignore`:
```
**/secrets.*
**/secrets_*
**/*_secrets.zsh
*.local
.gitconfig.local
```

---
## Phase 3: Split & Validate Brewfile 📦 DEPENDENCY MANAGEMENT
**Impact:** Medium | Complexity: Medium | Risk: Low

**New structure:**
```sh
brew/
├── .Brewfile              # Master file (includes others)
├── .Brewfile.core         # Essential CLI tools (stow, git, zsh)
├── .Brewfile.shell        # Shell enhancements (fzf, bat, eza)
├── .Brewfile.dev          # Development tools (gh, lazygit, k9s)
├── .Brewfile.desktop      # GUI apps (wezterm, aerospace)
└── .Brewfile.vscode       # VSCode extensions
```

Master `.Brewfile`:
```sh
# Core dependencies (required)
instance_eval(File.read("#{__dir__}/.Brewfile.core"))
# Shell tools (recommended)
instance_eval(File.read("#{__dir__}/.Brewfile.shell"))
# Optional - comment out if not needed
instance_eval(File.read("#{__dir__}/.Brewfile.dev"))
instance_eval(File.read("#{__dir__}/.Brewfile.desktop"))
instance_eval(File.read("#{__dir__}/.Brewfile.vscode"))
```

Add dependency verification script `scripts/verify-deps.sh`:
```zsh
#!/usr/bin/env zsh
# Verify all expected binaries exist
set -euo pipefail

declare -a REQUIRED_BINS=(
    "stow"
    "git"
    "zsh"
    "brew"
)

declare -a SHELL_BINS=(
    "fzf"
    "bat"
    "eza"
    "fd"
    "rg"
)

check_bins() {
    local -a missing=()
    for bin in "$@"; do
        if ! command -v "$bin" &>/dev/null; then
            missing+=("$bin")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "❌ Missing binaries: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

echo "Verifying core dependencies..."
check_bins "${REQUIRED_BINS[@]}"
echo "Verifying shell tools..."
check_bins "${SHELL_BINS[@]}"
echo "✅ All dependencies present"
```

---
## Phase 4: Robust setup.sh 🛠️ IDEMPOTENCY
**Impact:** High | Complexity: High | Risk: Medium

**Enhanced setup.sh:**
```zsh
#!/usr/bin/env zsh
# setup.sh - Idempotent dotfiles installation
# Usage: ./setup.sh [--force] [--skip-brew]
set -euo pipefail
# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color
log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
# Parse arguments
FORCE_INSTALL=false
SKIP_BREW=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --force) FORCE_INSTALL=true; shift ;;
        --skip-brew) SKIP_BREW=true; shift ;;
        *) log_error "Unknown option: $1"; exit 1 ;;
    esac
done
# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This setup script is for macOS only"
    exit 1
fi
# Function: Install Homebrew if needed
install_homebrew() {
    if command -v brew &>/dev/null; then
        log_info "Homebrew already installed at $(which brew)"
        return 0
    fi
    
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add to PATH for Apple Silicon
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}
# Function: Install dependencies from Brewfile
install_dependencies() {
    if [[ "$SKIP_BREW" == "true" ]]; then
        log_warn "Skipping Homebrew dependencies (--skip-brew)"
        return 0
    fi
    
    local brewfile="./brew/.Brewfile"
    
    if [[ ! -f "$brewfile" ]]; then
        log_error "Brewfile not found at $brewfile"
        return 1
    fi
    
    log_info "Installing dependencies from Brewfile..."
    brew bundle check --file="$brewfile" || \
        brew bundle install --file="$brewfile"
}
# Function: Setup dotfiles with stow
setup_dotfiles() {
    local packages=(aerospace brew git nvim starship vim wezterm zsh)
    
    log_info "Setting up dotfiles with GNU stow..."
    
    # Check for conflicts
    if ! stow -n -v "${packages[@]}" 2>&1; then
        log_warn "Stow conflicts detected!"
        
        if [[ "$FORCE_INSTALL" == "true" ]]; then
            log_warn "Force restowing (--force)..."
            stow -R -v "${packages[@]}"
        else
            log_error "Run with --force to override existing files"
            return 1
        fi
    else
        stow -v "${packages[@]}"
    fi
}
# Function: Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    if [[ -f "./scripts/verify-deps.sh" ]]; then
        ./scripts/verify-deps.sh
    else
        log_warn "Verification script not found, skipping"
    fi
}
# Main execution
main() {
    log_info "Starting dotfiles setup..."
    
    install_homebrew
    install_dependencies
    setup_dotfiles
    setup_git_config  # From Phase 2
    verify_installation
    
    log_info "✅ Setup complete!"
    log_info "Restart your terminal or run: exec zsh -l"
}
main "$@"
```
---
## Phase 5: Shell Safety & Shellcheck Compliance 🛡️ CODE QUALITY
**Impact:** Medium | Complexity: High | Risk: Low

Changes across all `.zsh` files:

1. Add shellcheck directives:
```sh
#!/usr/bin/env zsh
# shellcheck shell=bash
# shellcheck disable=SC1090  # Can't follow dynamic sources
set -euo pipefail
```
2. Fix PATH management in 01_path.zsh:
```sh
# Prevent duplicate PATH entries
add_to_path() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}
# Homebrew (architecture-aware)
if [[ -d "/opt/homebrew/bin" ]]; then
    add_to_path "/opt/homebrew/bin"
elif [[ -d "/usr/local/bin" ]]; then
    add_to_path "/usr/local/bin"
fi
# User binaries
add_to_path "$HOME/bin"
# Rancher Desktop
if [[ -d "$HOME/.rd/bin" ]]; then
    add_to_path "$HOME/.rd/bin"
fi
```
3. Improve 02_alias.zsh bba function:
```sh
# Install packages with Homebrew
bba() {
    local package="$1"
    local brewfile="$HOME/.Brewfile"
    
    # Validate inputs
    if [[ -z "${package:-}" ]]; then
        echo "Usage: bba <package_name>" >&2
        return 1
    fi
    
    if [[ ! -f "$brewfile" ]]; then
        echo "Error: Brewfile not found at $brewfile" >&2
        return 1
    fi
    
    # Add and install
    if brew bundle add --describe --file="$brewfile" "$package"; then
        brew bundle install --file="$brewfile"
    else
        echo "Failed to add $package to $brewfile" >&2
        return 1
    fi
}
```
4. Optimize 03_rust.zsh:
```sh
# Only check once per session
if [[ -z "${_RUST_CHECKED:-}" ]]; then
    if ! command -v rustc &>/dev/null; then
        log_warn "Rust not found. Install with: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    fi
    export _RUST_CHECKED=1
fi
# Source cargo env if available
if [[ -f "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi
```
5. Add guards to 02_autocompletion.zsh:
```sh
# Enable zsh-autosuggestions (if installed)
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
    log_warn "zsh-autosuggestions not found. Install with: brew install zsh-autosuggestions"
fi
```
Add `shellcheck` to `Brewfile.dev`:
```sh
brew "shellcheck"
brew "shfmt"
```

---
## Phase 6: Pre-commit Hooks 🎣 LOCAL VALIDATION
**Impact:** Medium | Complexity: Low | Risk: Low

Install pre-commit framework:
```sh
brew install pre-commit
```

Create `.pre-commit-config.yaml`:

```sh
repos:
  # Shell script validation
  - repo: https://github.com/shellcheck-py/shellcheck-py
    rev: v0.9.0.6
    hooks:
      - id: shellcheck
        args: ['--shell=bash', '--exclude=SC1090,SC1091']
        
  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.7.0-1
    hooks:
      - id: shfmt
        args: ['-i', '2', '-ci', '-w']
  # Lua formatting (for nvim/wezterm)
  - repo: https://github.com/JohnnyMorganz/StyLua
    rev: v0.20.0
    hooks:
      - id: stylua
  # General file cleanup
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: detect-private-key
        exclude: '\.pub$'
      - id: check-case-conflict
      
  # Prevent commits with secrets
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
  # Custom validation
  - repo: local
    hooks:
      - id: verify-deps
        name: Verify dependencies
        entry: ./scripts/verify-deps.sh
        language: script
        pass_filenames: false
```  

Install hooks:
```sh
pre-commit install
pre-commit run --all-files  # Initial run
```

Update or create the contributing sectionn of the README.md file.

---
## Phase 7: CI/CD Pipeline ⚙️ CONTINUOUS VALIDATION
**Impact:** Medium | Complexity: Medium | Risk: Low

Create `.github/workflows/validate.yml`:
```yml
name: Validate Dotfiles
on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]
jobs:
  shellcheck:
    name: Shell Script Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run shellcheck
        uses: ludeeus/action-shellcheck@master
        with:
          severity: warning
          
  shfmt:
    name: Shell Formatting
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install shfmt
        run: |
          wget -O /usr/local/bin/shfmt https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.7.0_linux_amd64
          chmod +x /usr/local/bin/shfmt
          
      - name: Check formatting
        run: shfmt -i 2 -ci -d .
        
  lua-style:
    name: Lua Formatting (Neovim/WezTerm)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Stylua Check
        uses: JohnnyMorganz/stylua-action@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          version: latest
          args: --check .
          
  brewfile:
    name: Validate Brewfile
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Validate Brewfile syntax
        run: |
          brew bundle check --file=./brew/.Brewfile || true
          
  integration:
    name: Integration Test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Test setup script (dry run)
        run: |
          # Mock brew install
          export SKIP_BREW=true
          ./setup.sh --skip-brew || true
          
      - name: Test stow (dry run)
        run: |
          brew install stow
          stow -n -v aerospace brew git nvim starship vim wezterm zsh
```
---
## Phase 8: Enhanced Documentation 📚 USABILITY
**Impact:** Low | Complexity: Low | Risk: None

Improved `README.md`:
<details>
<summary>Improved `README.md`</summary>
 Dotfiles - Pierre's Personal Configuration
Modern, XDG-compliant dotfiles for macOS using GNU Stow.
 Features
- 🚀 **Fast setup** - One command to configure a new Mac
- 📦 **Modular** - Split Brewfiles for different contexts
- 🔒 **Secure** - Template-based config for personal info
- ✅ **Validated** - CI/CD + pre-commit hooks
- 🎯 **XDG-compliant** - Follows modern standards
 Quick Start
# Clone repository
git clone git@github.com:pith/.dotfiles.git ~/dotfiles
cd ~/dotfiles
# Run setup (installs Homebrew, dependencies, symlinks)
./setup.sh
Structure
dotfiles/
├── setup.sh              # Main installation script
├── scripts/              # Utility scripts
│   └── verify-deps.sh    # Dependency verification
├── brew/
│   ├── .Brewfile         # Master dependency file
│   ├── .Brewfile.core    # Essential tools
│   ├── .Brewfile.shell   # Shell enhancements
│   └── .Brewfile.dev     # Development tools
├── git/
│   ├── .gitconfig.template
│   └── .gitconfig.local.example
├── zsh/
│   ├── .zshrc
│   └── .config/zsh/      # Modular configuration
│       ├── 01_path.zsh
│       ├── 02_*.zsh
│       └── 03_*.zsh
└── [other tool configs]
Customization
Personal Git Config
Copy the example file and customize:
cp git/.gitconfig.local.example ~/.gitconfig.local
vim ~/.gitconfig.local
Optional Dependencies
Edit brew/.Brewfile to comment out packages you don't need:
# instance_eval(File.read("#{__dir__}/.Brewfile.desktop"))  # Skip GUI apps
Machine-Specific Config
Create files matching these patterns (auto-ignored by git):
- **/secrets.zsh
- **/secrets_*.zsh
- **/*.local
Maintenance
# Update dependencies
brew bundle install --file=./brew/.Brewfile
# Verify all tools present
./scripts/verify-deps.sh
# Re-apply symlinks
stow -R aerospace brew git nvim starship vim wezterm zsh
# Run validation
pre-commit run --all-files
Troubleshooting
Stow Conflicts
If stow reports conflicts:
# Check what's conflicting
stow -n -v zsh
# Force restow (overwrites existing)
./setup.sh --force
Missing Dependencies
# Check what's missing
./scripts/verify-deps.sh
# Reinstall specific package
brew bundle install --file=./brew/.Brewfile
Shell Not Loading
# Test config in isolation
zsh -c 'source ~/.zshrc && echo "OK"'
# Check for errors
zsh -x -c 'source ~/.zshrc' 2>&1 | less
Contributing
This is a personal repo, but feel free to fork and adapt!
1. Fork the repository
2. Create a feature branch
3. Make changes (pre-commit hooks will validate)
4. Submit a PR
License
MIT License - See LICENSE (LICENSE)
**Add `MIGRATION.md`:**
```markdown
# Migration Guide
## Upgrading from Old Structure
If you're upgrading from the old structure (before XDG migration):
### Backup
```bash
cp ~/.zshrc ~/.zshrc.old
cp -r ~/dotfiles/zsh-config ~/dotfiles/zsh-config.backup
Manual Steps
1. Pull latest changes: git pull origin master
2. Re-run setup: ./setup.sh --force
3. Restart terminal: exec zsh -l
4. Verify: echo $ZDOTDIR (should show ~/.config/zsh)
Cleanup
# Remove old symlinks
rm ~/01_path.zsh ~/02_*.zsh ~/03_*.zsh
# Remove backup
rm -rf ~/dotfiles/zsh-config.backup

---
### **Phase 9: Advanced Features** 🚀 ENHANCEMENTS
**Impact:** Low | **Complexity:** Medium | **Risk:** Low

**Create `scripts/bootstrap.sh`** (for fresh Mac):
```bash
#!/usr/bin/env zsh
# Bootstrap a completely fresh Mac
set -euo pipefail
# Install Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    # Wait for installation
    until xcode-select -p &>/dev/null; do
        sleep 5
    done
fi
# Clone dotfiles if not present
if [[ ! -d "$HOME/dotfiles" ]]; then
    echo "Cloning dotfiles repository..."
    git clone git@github.com:pith/.dotfiles.git "$HOME/dotfiles"
fi
# Run setup
cd "$HOME/dotfiles"
./setup.sh
Create scripts/update.sh:
#!/usr/bin/env zsh
# Update all dotfiles and dependencies
set -euo pipefail
echo "Updating dotfiles repository..."
git pull --rebase
echo "Updating Homebrew..."
brew update
echo "Upgrading packages..."
brew bundle install --file=./brew/.Brewfile
echo "Cleaning up..."
brew cleanup
brew autoremove
echo "Re-applying symlinks..."
stow -R aerospace brew git nvim starship vim wezterm zsh
echo "✅ Update complete!"
Create scripts/doctor.sh:
#!/usr/bin/env zsh
# Diagnose dotfiles installation issues
set -euo pipefail
echo "=== Dotfiles Health Check ==="
echo ""
# Check OS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "❌ Not running on macOS"
else
    echo "✅ macOS detected: $(sw_vers -productVersion)"
fi
# Check Homebrew
if command -v brew &>/dev/null; then
    echo "✅ Homebrew installed: $(brew --version | head -1)"
else
    echo "❌ Homebrew not found"
fi
# Check stow
if command -v stow &>/dev/null; then
    echo "✅ GNU Stow installed"
else
    echo "❌ GNU Stow not found"
fi
# Check symlinks
echo ""
echo "=== Symlink Status ==="
for file in .zshrc .gitconfig .vimrc .wezterm.lua; do
    if [[ -L "$HOME/$file" ]]; then
        target=$(readlink "$HOME/$file")
        if [[ -e "$HOME/$file" ]]; then
            echo "✅ $file -> $target"
        else
            echo "⚠️  $file -> $target (broken)"
        fi
    else
        echo "❌ $file not symlinked"
    fi
done
# Check dependencies
echo ""
echo "=== Core Dependencies ==="
./scripts/verify-deps.sh
echo ""
echo "=== Shell Check ==="
if zsh -c 'source ~/.zshrc' &>/dev/null; then
    echo "✅ Shell configuration loads successfully"
else
    echo "❌ Shell configuration has errors"
fi
```

---
## Phase 10: Cleanup & Polish ✨ FINAL TOUCHES
Impact: Low | Complexity: Low | Risk: None

Remove redundancies:
1. Delete wezterm/.wezterm.lua.copy (appears to be backup)
2. Remove powerlevel10k from Brewfile (using starship)
3. Clean up commented NVM code in 03_node.zsh

Improve .gitignore:
```
# Secrets
**/secrets.*
**/secrets_*
**/*_secrets.zsh
*.local
# Editor
*.swp
*.swo
*.swn
*~
.DS_Store
# LazyVim
tt.*
.tests
doc/tags
debug
.repro
foo.*
*.log
data
# Neovim
nvim/.config/nvim/lazy-lock.json
# Local overrides
*.local
.gitconfig.local
# Pre-commit
.secrets.baseline
```

Add useful Makefile:
```Makefile
.PHONY: help install update lint format test doctor clean
help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
install:  ## Install dotfiles
	./setup.sh
update:  ## Update dotfiles and dependencies
	./scripts/update.sh
lint:  ## Lint shell scripts
	@echo "Running shellcheck..."
	@find . -name "*.sh" -o -name "*.zsh" | xargs shellcheck
	@echo "Running shfmt check..."
	@shfmt -i 2 -ci -d .
format:  ## Format shell scripts
	@echo "Formatting with shfmt..."
	@shfmt -i 2 -ci -w .
	@echo "Formatting Lua..."
	@stylua .
test:  ## Run all validations
	@pre-commit run --all-files
doctor:  ## Diagnose installation issues
	./scripts/doctor.sh
clean:  ## Remove symlinks
	stow -D aerospace brew git nvim starship vim wezterm zsh
bootstrap:  ## Bootstrap fresh Mac
	./scripts/bootstrap.sh
```

---
## 📝 Implementation Checklist
Here's the step-by-step execution plan (safe & incremental):

Week 1: Architecture & Critical Fixes
- [ ] Phase 1: Migrate to XDG structure (test thoroughly!)
- [ ] Phase 2: Implement git config templates
- [ ] Test on a fresh shell session
- [ ] Commit & push (create backup branch first)
Week 2: Dependencies & Safety
- [ ] Phase 3: Split Brewfile into modules
- [ ] Phase 5: Apply shellcheck fixes to all scripts
- [ ] Add verification script
- [ ] Test installation on VM/separate account
Week 3: Automation
- [ ] Phase 4: Rewrite setup.sh with idempotency
- [ ] Phase 6: Add pre-commit hooks
- [ ] Phase 9: Create utility scripts (bootstrap, update, doctor)
- [ ] Test complete installation flow
Week 4: CI/CD & Documentation
- [ ] Phase 7: Setup GitHub Actions
- [ ] Phase 8: Write comprehensive README
- [ ] Phase 10: Cleanup & polish
- [ ] Final testing & validation
---

🎓 Key Learnings & Best Practices
State-of-the-Art Dotfiles Patterns
1. XDG Base Directory Standard
   - ~/.config/ for configs
   - ~/.local/share/ for data
   - ~/.cache/ for cache
   - Keeps $HOME clean
2. Template-Based Personal Info
   - Never commit emails/names
   - Use .local files for overrides
   - Document with .example files
3. Modular Dependencies
   - Split by context (core, desktop, dev)
   - Easy to customize per machine
   - Faster minimal installs
4. Idempotent Setup Scripts
   - Can run multiple times safely
   - Check before install
   - Meaningful error messages
5. Guard All Configs
   - Check dependencies before use
   - Graceful degradation
   - Helpful error messages
6. Automated Validation
   - Pre-commit hooks catch errors early
   - CI/CD prevents broken commits
   - Shell safety with shellcheck

Anti-Patterns to Avoid (found in current repo)
❌ Hardcoded paths - Use $(brew --prefix), $HOME, ${0:a:h}  
❌ Unguarded sourcing - Check file exists before source  
❌ PATH pollution - Deduplicate on every reload  
❌ Personal info in repo - Use templates  
❌ Non-idempotent scripts - Check state before modify  
❌ Conflicting tools - Remove powerlevel10k if using starship  
❌ Silent failures - Add verbose error handling  
❌ No validation - Add pre-commit + CI  
---

## 🔧 Code Quality Improvements Summary
Shell Script Quality (Current → Target)
| Aspect | Current | Target | Impact |
|--------|---------|--------|--------|
| Shellcheck compliance | ❌ No | ✅ All files | High |
| Quoting | ⚠️ Partial | ✅ All vars | Medium |
| Error handling | ⚠️ Basic | ✅ Comprehensive | High |
| Idempotency | ❌ No | ✅ Yes | Critical |
| Documentation | ⚠️ Minimal | ✅ Complete | Medium |
| Testing | ❌ Manual only | ✅ Automated | High |

Architecture Quality
| Aspect | Current | Target | Impact |
|--------|---------|--------|--------|
| XDG compliance | ❌ No | ✅ Yes | High |
| Personal info | ❌ Committed | ✅ Templated | Critical |
| Modularity | ⚠️ Partial | ✅ Full | Medium |
| Dependency mgmt | ⚠️ Monolithic | ✅ Split | Medium |
| Path management | ❌ Duplicates | ✅ Deduplicated | Low |
---
# 💡 Recommended Reading
To deepen your dotfiles expertise:
1. XDG Base Directory Spec: https://specifications.freedesktop.org/basedir-spec/
2. Stow Manual: https://www.gnu.org/software/stow/manual/stow.html
3. Shellcheck Wiki: https://www.shellcheck.net/wiki/
4. Dotfiles Best Practices: https://dotfiles.github.io/
5. Brew Bundle: https://github.com/Homebrew/homebrew-bundle
---
❓ Questions for You
Before I create implementation PRs:
1. Testing environment: Do you have a VM or spare Mac to test changes safely? - No
2. Backward compatibility: Should we support old structure temporarily with migration script? - Yes to allow easy migration on other computers
3. Additional tools: Any other tools you use that should be in the Brewfile? - Not that I can think of
4. Company laptop: Is this for personal + work? (affects secrets strategy) – I have both a personal and company laptop
5. Priority phases: Want to tackle specific phases first or follow the 4-week plan? - Follow the plan
---

