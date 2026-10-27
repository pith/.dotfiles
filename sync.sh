#!/bin/zsh

# sync.sh - Pull latest dotfiles from remote and reconcile local state
# Safe to run repeatedly after every git pull.
# Usage: ./sync.sh [--skip-brew]
#   --skip-brew  Skip Homebrew bundle install

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DOTFILES_DIR/lib.zsh"

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
  brew update
  # Non-fatal: mas (Mac App Store) installs require interactive auth and may
  # fail in a non-GUI session. Stow and TPM updates should still run.
  brew bundle install --file="$brewfile" \
    || log_warn "brew bundle errors — MAS apps may need interactive install"
  brew upgrade

  # ffmpeg-full and imagemagick-full are keg-only (conflict with non-full variants);
  # force-link them so their binaries are available on PATH.
  brew link ffmpeg-full imagemagick-full -f --overwrite 2>/dev/null || true
}

update_submodules() {
  log_info "Updating git submodules..."
  # Checks out the pinned commits recorded in the repo after the pull.
  git -C "$DOTFILES_DIR" submodule update --init --recursive
}

restow_dotfiles() {
  log_info "Restowing dotfiles..."
  prepare_stow_targets
  stow -R "${STOW_PACKAGES[@]}"
}

update_tpm_plugins() {
  local tpm_updater="$HOME/.tmux/plugins/tpm/bin/update_plugins"
  if [[ -x "$tpm_updater" ]]; then
    log_info "Updating TPM plugins..."
    "$tpm_updater" all
  else
    log_warn "TPM not found at $tpm_updater — skipping plugin update"
  fi
}

# herdr-plugin-sesh reads sesh.toml through its deprecated Sesh-compatible schema;
# warn if an auto-update above dropped that support.
check_sesh_plugin_config() {
  command -v herdr &>/dev/null || return 0
  local sesh_config="$HOME/.config/sesh/sesh.toml" plugin_root
  plugin_root="$(herdr plugin list --json | jq -r '.result.plugins[] | select(.plugin_id == "fullerzz.sesh") | .plugin_root')"
  if [[ -z "$plugin_root" || ! -f "$sesh_config" ]]; then
    return 0
  fi
  if ! "$plugin_root/bin/herdr-sesh" config validate "$sesh_config" >/dev/null 2>&1; then
    log_warn "herdr-plugin-sesh can no longer read $sesh_config (legacy Sesh schema support may be gone): herdr prefix+t is broken, tmux sesh is unaffected."
    log_warn "Reinstall a working release with: herdr plugin install fullerzz/herdr-plugin-sesh --ref <tag> --yes"
  fi
}

#### Main ####

main() {
  log_info "Syncing dotfiles..."

  pull_latest
  update_submodules
  update_dependencies
  restow_dotfiles
  update_tpm_plugins
  install_herdr_plugins --update
  check_sesh_plugin_config

  log_info "Sync complete! Restart your terminal or run: exec zsh -l"
}

main "$@"
