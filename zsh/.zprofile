
# mise shims for non-interactive sessions (scripts, CI, cron)
if [[ -z "$MISE_SHELL" ]] && command -v mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
