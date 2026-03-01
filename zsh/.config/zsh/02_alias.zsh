#### ZSH alias ####

# Git
alias gst="git status"
alias gpl="git pull --ff-only origin \$(git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')"
alias gc="git commit"
alias gca="git add -A && git commit"
alias gcam="git add -A && git commit --amend"
alias gcaM="git add -A && git commit --amend --no-edit"
alias gcm="git po"

# Navigation with cd & eza
alias ..='cd ..'
alias ...='cd ../..'
alias la="eza -la"
alias l="ls -lah"
alias ll="eza --icons -1 --git-ignore --group-directories-first"
alias lll="eza -TL 1 --git-ignore --group-directories-first"

# Replace cat with its bat alternative
alias cat="bat"

# shortcut to capture dotfiles
alias capt="~/dotfiles/capture.sh"

## Zoxide
if [[ -o interactive ]]; then
  eval "$(zoxide init zsh --cmd cd)"
else
  eval "$(zoxide init zsh --no-cmd)"
fi

alias vim="nvim"

# Install packages with Homebrew
bba() {
  local package="$1"
  local brewfile=~/.Brewfile

  # Check if the package name exists
  if [[ -z "$package" ]]; then
    echo "Usage: bba <package_name>"
    return 1
  fi

  # Add package to Brewfile and install it
  if brew bundle add --describe --file="$brewfile" "$package"; then
    brew bundle install --file="$brewfile"
  else
    echo "Failed to add $package to $brewfile." >&2
    return 1
  fi
}

# Manage dotfiles
alias dot="vim ~/dotfiles"
alias dd="source ~/.zshrc"

# Lazy git
alias lg="lazygit"
