# Activate mise for interactive sessions (idempotent — skips if already active)
if [[ -z "$MISE_SHELL" ]] && command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi
