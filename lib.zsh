# lib.zsh - Shared lists and helpers for bootstrap.sh and sync.sh
# Sourced, not executed. Single source of truth for what gets stowed and installed.

#### Shared Lists ####

# Stow packages (repo dirs mirroring $HOME), alphabetical
STOW_PACKAGES=(aerospace bat brew eza git herdr lazygit mise nvim ripgrep sesh starship tmux wezterm yazi zsh)

# herdr plugins as GitHub owner/repo, alphabetical
HERDR_PLUGINS=(aimdevlee/herdr-nvim-nav fullerzz/herdr-plugin-sesh qu8n/herdr-automatic-rename)

#### Logging ####

log_info()  { print -P "%F{green}[INFO]%f $*"; }
log_warn()  { print -P "%F{yellow}[WARN]%f $*"; }
log_error() { print -P "%F{red}[ERROR]%f $*" >&2; }

#### Shared Functions ####

# Pre-create dirs that tools write runtime state into, so stow links the files
# inside them instead of folding the whole dir into a symlink to the repo.
prepare_stow_targets() {
  mkdir -p "$HOME/.config/herdr" # herdr writes its socket, plugins and session state here
}

# Install missing herdr plugins and the Claude Code integration.
# Usage: install_herdr_plugins [--update]  (--update also updates installed plugins)
install_herdr_plugins() {
  if ! command -v herdr &>/dev/null; then
    log_warn "herdr not found — skipping plugin install"
    return 0
  fi
  local installed plugin
  installed="$(herdr plugin list --json | jq -r '.result.plugins[].source | select(.kind == "github") | "\(.owner)/\(.repo)"')"
  for plugin in "${HERDR_PLUGINS[@]}"; do
    if ! grep -qx "$plugin" <<< "$installed"; then
      log_info "Installing herdr plugin $plugin..."
      herdr plugin install "$plugin" --yes
    fi
  done
  if [[ "${1:-}" == "--update" ]]; then
    log_info "Updating herdr plugins..."
    herdr plugin update --yes
  fi
  # Claude Code session hook (lets herdr resume Claude sessions); needs ~/.claude to exist
  if [[ -d "$HOME/.claude" ]]; then
    herdr integration install claude
  fi
}
