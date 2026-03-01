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

# Create local directory for machine-specific secrets (not in git)
mkdir -p ~/.config/zsh/local

# Setup git local config if it doesn't exist
if [ ! -f "$HOME/.gitconfig.local" ]; then
  echo ''
  echo 'Setting up git local config...'
  echo ''
  read "git_name?Enter your name for git: "
  read "git_email?Enter your email for git: "
  read "git_signingkey?Enter your SSH signing key path (default: ~/.ssh/id_ed25519.pub): "
  git_signingkey="${git_signingkey:-~/.ssh/id_ed25519.pub}"

  cat > "$HOME/.gitconfig.local" << EOF
[user]
	name = $git_name
	email = $git_email
	signingkey = $git_signingkey
EOF
  echo 'Git local config created at ~/.gitconfig.local'
fi
