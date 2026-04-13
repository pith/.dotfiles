#!/bin/zsh

# sync.sh - Pull latest dotfiles from remote and reconcile local state
# Safe to run repeatedly after every git pull.
# Usage: ./sync.sh [--skip-brew]
#   --skip-brew  Skip Homebrew bundle install

set -euo pipefail

#### Logging ####

log_info()  { print -P "%F{green}[INFO]%f $*"; }
log_warn()  { print -P "%F{yellow}[WARN]%f $*"; }
log_error() { print -P "%F{red}[ERROR]%f $*" >&2; }

#### Argument Parsing ####

SKIP_BREW=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --skip-brew) SKIP_BREW=true; shift ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

#### Pre-flight Checks ####

if [[ "$(uname)" != "Darwin" ]]; then
  log_error "This script is for macOS only"
  exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

#### Functions ####

pull_latest() {
  log_info "Pulling latest changes..."

  local stashed=false

  # Stash WIP so git pull --ff-only doesn't abort on dirty files.
  # [pull] ff = only is set globally; rebase.autostash only covers rebases.
  if [[ -n "$(git -C "$DOTFILES_DIR" status --porcelain)" ]]; then
    log_warn "Working tree is dirty — stashing changes before pull"
    git -C "$DOTFILES_DIR" stash push --include-untracked -m "sync.sh auto-stash"
    stashed=true
  fi

  if ! git -C "$DOTFILES_DIR" pull --ff-only; then
    if [[ "$stashed" == true ]]; then
      log_warn "Pull failed — restoring stash"
      git -C "$DOTFILES_DIR" stash pop
    fi
    log_error "Pull failed: branch has diverged. Resolve manually, then re-run sync."
    return 1
  fi

  if [[ "$stashed" == true ]]; then
    log_info "Restoring stashed changes"
    git -C "$DOTFILES_DIR" stash pop
  fi
}

update_dependencies() {
  if [[ "$SKIP_BREW" == true ]]; then
    log_warn "Skipping Homebrew dependencies (--skip-brew)"
    return 0
  fi

  local brewfile="$DOTFILES_DIR/brew/.Brewfile"
  if [[ ! -f "$brewfile" ]]; then
    log_error "Brewfile not found at $brewfile"
    return 1
  fi

  log_info "Updating dependencies from Brewfile..."
  brew bundle check --file="$brewfile" 2>/dev/null \
    || brew bundle install --file="$brewfile"

  # ffmpeg-full and imagemagick-full are keg-only (conflict with non-full variants);
  # force-link them so their binaries are available on PATH.
  brew link ffmpeg-full imagemagick-full -f --overwrite 2>/dev/null || true
}

restow_dotfiles() {
  local -a packages=(aerospace bat brew eza git lazygit mise nvim ripgrep sesh starship tmux vim wezterm yazi zsh)

  log_info "Restowing dotfiles..."
  stow -R "${packages[@]}"
}

#### Main ####

main() {
  log_info "Syncing dotfiles..."

  pull_latest
  update_dependencies
  restow_dotfiles

  log_info "Sync complete! Restart your terminal or run: exec zsh -l"
}

main "$@"
