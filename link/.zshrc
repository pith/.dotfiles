#!/usr/bin/env zsh

# Where the magic happens.
export DOTFILES=~/.dotfiles

# Add binaries into the path
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

# Run dotfiles script, then source.
function dot() {
  '$DOTFILES/bin/dotfiles run' && src && . ~/.zshrc
}

src

# User configuration
export DEV="$HOME/dev"
