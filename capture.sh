#!/bin/zsh

# capture.sh - Capture config files for dotfiles management with GNU stow
# Usage: capture <source_path> <config_name>
# Example: capture ~/.zsh zsh

set -euo pipefail

# Function to display usage
usage() {
    echo "Usage: $0 <source_path> <config_name>"
    echo ""
    echo "Captures a config file or directory and moves it to the dotfiles structure"
    echo "for GNU stow management."
    echo ""
    echo "Examples:"
    echo "  $0 ~/.zsh zsh           # Moves ~/.zsh to ~/dotfiles/zsh/.zsh"
    echo "  $0 ~/.vimrc vim         # Moves ~/.vimrc to ~/dotfiles/vim/.vimrc"
    echo "  $0 ~/.config/git git    # Moves ~/.config/git to ~/dotfiles/git/.config/git"
    echo ""
    echo "The captured files will be placed in ~/dotfiles/<config_name>/<captured_path>"
    exit 1
}

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Error: Wrong number of arguments"
    usage
fi

SOURCE_PATH="$1"
CONFIG_NAME="$2"

# Expand tilde to full home path
SOURCE_PATH="${SOURCE_PATH/#\~/$HOME}"

# Define dotfiles directory
DOTFILES_DIR="$HOME/dotfiles"

# Check if source path exists
if [ ! -e "$SOURCE_PATH" ]; then
    echo "Error: Source path '$SOURCE_PATH' does not exist"
    exit 1
fi

# Create dotfiles directory if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Creating dotfiles directory: $DOTFILES_DIR"
    mkdir -p "$DOTFILES_DIR"
fi

# Create config directory
CONFIG_DIR="$DOTFILES_DIR/$CONFIG_NAME"
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
fi

# Determine the relative path from home directory
if [[ "$SOURCE_PATH" == "$HOME"* ]]; then
    # Path is under home directory
    REL_PATH="${SOURCE_PATH#$HOME/}"
    DEST_PATH="$CONFIG_DIR/$REL_PATH"
else
    # Path is not under home directory (e.g., /etc/something)
    # In this case, we'll preserve the full path structure
    DEST_PATH="$CONFIG_DIR$SOURCE_PATH"
fi

# Create destination directory structure
DEST_DIR="$(dirname "$DEST_PATH")"
if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

# Check if destination already exists
if [ -e "$DEST_PATH" ]; then
    echo "Warning: Destination '$DEST_PATH' already exists"
    read -q "REPLY?Do you want to overwrite it? (y/N): "
    echo
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted"
        exit 1
    fi
    rm -rf "$DEST_PATH"
fi

# Move the file/directory
mv "$SOURCE_PATH" "$DEST_PATH"

# Create symlink back to original location
ln -sf "$DEST_PATH" "$SOURCE_PATH"

echo ""
echo "✅ Successfully captured '$SOURCE_PATH' as '$CONFIG_NAME'"
echo "🔗 Symlink created: $SOURCE_PATH -> $DEST_PATH"
