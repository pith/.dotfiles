#!/bin/zsh

# setup.sh - Initialize a new Mac with Brew dependencies and dotfiles
# Usage: ./setup.sh

set -euo pipefail

# Install brew
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

# Install 
brew bundle --file ./brew/.Brewfile

# Setup dotfiles (create symlinks with GNU stow
stow aerospace brew git starship vim wezterm
