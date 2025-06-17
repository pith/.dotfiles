#### ZSH alias ####

# Git
alias gst="git status"

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
eval "$(zoxide init zsh --cmd cd)"

alias vim="nvim"

# Alias to install packages with Homebrew
alias bi="brew bundle add --file=~/.Brewfile"
