#!/bin/zsh

# setup.sh - Idempotent dotfiles installation for macOS
# Usage: ./setup.sh [--force] [--skip-brew]
#   --force      Override existing files when stow conflicts are detected
#   --skip-brew  Skip Homebrew installation and bundle install

set -euo pipefail

#### Logging ####

log_info()  { print -P "%F{green}[INFO]%f $*"; }
log_warn()  { print -P "%F{yellow}[WARN]%f $*"; }
log_error() { print -P "%F{red}[ERROR]%f $*" >&2; }

#### Argument Parsing ####

FORCE_INSTALL=false
SKIP_BREW=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --force)     FORCE_INSTALL=true; shift ;;
    --skip-brew) SKIP_BREW=true; shift ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

#### Pre-flight Checks ####

if [[ "$(uname)" != "Darwin" ]]; then
  log_error "This setup script is for macOS only"
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

#### Functions ####

install_homebrew() {
  if command -v brew &>/dev/null; then
    log_info "Homebrew already installed: $(brew --version | head -1)"
    return 0
  fi

  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH immediately for Apple Silicon Macs
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

install_dependencies() {
  if [[ "$SKIP_BREW" == true ]]; then
    log_warn "Skipping Homebrew dependencies (--skip-brew)"
    return 0
  fi

  local brewfile="$DOTFILES_DIR/brew/.Brewfile"
  if [[ ! -f "$brewfile" ]]; then
    log_error "Brewfile not found at $brewfile"
    return 1
  fi

  log_info "Installing dependencies from Brewfile..."
  # Only run install if something is missing — avoids slow full reinstall
  brew bundle check --file="$brewfile" 2>/dev/null \
    || brew bundle install --file="$brewfile"
}

setup_dotfiles() {
  local -a packages=(aerospace brew git nvim ripgrep sesh starship tmux vim wezterm yazi zsh)

  log_info "Setting up dotfiles with GNU stow..."

  # Dry-run to detect conflicts before touching anything
  if stow -n "${packages[@]}" 2>/dev/null; then
    stow "${packages[@]}"
  else
    log_warn "Stow conflicts detected. Inspect with: stow -n -v ${packages[*]}"
    if [[ "$FORCE_INSTALL" == true ]]; then
      log_warn "Restowing with --force..."
      stow -R "${packages[@]}"
    else
      log_error "Resolve conflicts manually or rerun with --force to override"
      return 1
    fi
  fi

  # Ensure machine-local secrets directory exists (gitignored, never stowed)
  mkdir -p "$HOME/.config/zsh/local"

  if command -v pre-commit &>/dev/null; then
    log_info "Installing pre-commit hooks..."
    (cd "$DOTFILES_DIR" && pre-commit install)
  fi
}

setup_git_config() {
  if [[ -f "$HOME/.gitconfig.local" ]]; then
    log_info "Git local config already exists at ~/.gitconfig.local"
    return 0
  fi

  log_info "Setting up git local config..."

  local git_name git_email git_signingkey
  read "git_name?Enter your name for git: "
  read "git_email?Enter your email for git: "
  read "git_signingkey?Enter your SSH signing key path (default: ~/.ssh/id_ed25519.pub): "
  git_signingkey="${git_signingkey:-~/.ssh/id_ed25519.pub}"

  cat > "$HOME/.gitconfig.local" << EOF
[user]
	name = $git_name
	email = $git_email
	signingkey = $git_signingkey
EOF

  log_info "Git local config created at ~/.gitconfig.local"
}

#### Main ####

main() {
  log_info "Starting dotfiles setup..."

  install_homebrew
  install_dependencies
  setup_dotfiles
  setup_git_config

  log_info "Setup complete! Restart your terminal or run: exec zsh -l"
}

main "$@"
