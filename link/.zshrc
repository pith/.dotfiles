#!/usr/bin/env zsh

export DOTFILES=~/.dotfiles

# Add dotfiles binaries into the path
PATH=$DOTFILES/bin:$PATH
export PATH

# Source all files in "source"
function src() {
  local file
  if [ "$1" ]; then
    source "$DOTFILES/source/$1.sh"
  else
    for file in $DOTFILES/source/*; do
      source "$file"
    done
  fi
}

src

# User configuration
export DEV="$HOME/workspace"

# Initialize the startship prompt (https://starship.rs/)
eval "$(starship init zsh)"
