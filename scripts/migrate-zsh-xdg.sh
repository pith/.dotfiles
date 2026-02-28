#!/bin/zsh

# migrate-zsh-xdg.sh - Migrate from old zsh-config/ layout to XDG-compliant ~/.config/zsh/
# Usage: ./scripts/migrate-zsh-xdg.sh
#
# Run this after `git pull` on machines still using the old ~/dotfiles/zsh-config/ layout.
# It moves secret/local files to the new location and re-stows the zsh package.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OLD_DIR="$DOTFILES_DIR/zsh-config"
NEW_LOCAL_DIR="$DOTFILES_DIR/zsh/.config/zsh/local"

if [ ! -d "$OLD_DIR" ]; then
  echo "Nothing to migrate: $OLD_DIR does not exist."
  echo "You're already on the new layout."
  exit 0
fi

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
echo "Migration complete. Verify with: zsh -c 'source ~/.zshrc && echo OK'"
