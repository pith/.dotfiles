#!/bin/zsh

# migrate.sh - Run migrations after pulling new dotfiles changes
# Usage: ./scripts/migrate.sh
#
# Handles:
# 1. Zsh XDG migration (old zsh-config/ → ~/.config/zsh/)
# 2. Git config migration (hardcoded [user] → ~/.gitconfig.local)

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

#### Zsh XDG Migration ####

OLD_DIR="$DOTFILES_DIR/zsh-config"
NEW_LOCAL_DIR="$DOTFILES_DIR/zsh/.config/zsh/local"

if [ -d "$OLD_DIR" ]; then
  echo "Migrating secret files from $OLD_DIR to $NEW_LOCAL_DIR..."
  mkdir -p "$NEW_LOCAL_DIR"

  moved=0
  for f in "$OLD_DIR"/secret_*.zsh(N) "$OLD_DIR"/secrets_*.zsh(N); do
    if [ -f "$f" ]; then
      mv "$f" "$NEW_LOCAL_DIR/"
      echo "  Moved: $(basename "$f")"
      moved=$((moved + 1))
    fi
  done

  if [ "$moved" -eq 0 ]; then
    echo "  No secret files found to move."
  fi

  # Remove old directory if empty
  if [ -z "$(ls -A "$OLD_DIR" 2>/dev/null)" ]; then
    rmdir "$OLD_DIR"
    echo "Removed empty $OLD_DIR"
  else
    echo "Warning: $OLD_DIR still contains files:"
    ls "$OLD_DIR"
    echo "Please move or remove them manually."
  fi

  # Re-stow zsh package
  echo "Re-stowing zsh package..."
  cd "$DOTFILES_DIR"
  stow -R zsh

  echo ""
  echo "Zsh migration complete. Verify with: zsh -c 'source ~/.zshrc && echo OK'"
else
  echo "Zsh XDG migration: nothing to do (already on new layout)."
fi

#### Git Config Migration ####

if [ -f "$HOME/.gitconfig.local" ]; then
  echo "Git config migration: ~/.gitconfig.local already exists, skipping."
else
  echo ""
  echo "Migrating git config to ~/.gitconfig.local..."

  git_name="$(git config --global user.name 2>/dev/null || true)"
  git_email="$(git config --global user.email 2>/dev/null || true)"
  git_signingkey="$(git config --global user.signingkey 2>/dev/null || true)"

  if [ -n "$git_name" ] || [ -n "$git_email" ]; then
    cat > "$HOME/.gitconfig.local" << EOF
[user]
	name = ${git_name:-Your Name}
	email = ${git_email:-your.email@example.com}
	signingkey = ${git_signingkey:-~/.ssh/id_ed25519.pub}
EOF
    echo "Created ~/.gitconfig.local with:"
    echo "  name = $git_name"
    echo "  email = $git_email"
    echo "  signingkey = ${git_signingkey:-(default)}"
  else
    echo "No existing git user config found."
    echo "Copy git/.gitconfig.local.example to ~/.gitconfig.local and customize it."
  fi
fi

echo ""
echo "All migrations complete."
