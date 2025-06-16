#!/bin/zsh

# setup.sh - Initialize a new Mac with Brew dependencies and dotfiles
# Usage: ./setup.sh

set -euo pipefail

# Install brew
echo ''
echo 'Installing Homebrew...'
echo ''
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install 
echo ''
echo 'Homebrew is installed. Installing dependencies...'
echo ''
brew bundle --file ./brew/.Brewfile

# Setup dotfiles (create symlinks with GNU stow
echo ''
echo 'Setting up dotfiles...'
echo ''
stow aerospace brew git nvim starship vim wezterm zsh
