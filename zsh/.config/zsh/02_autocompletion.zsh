##### History completion ####
# Inspired from https://dev.to/rossijonas/how-to-set-up-history-based-autocompletion-in-zsh-k7o

# AUTOCOMPLETION

# initialize autocompletion
autoload -U compinit && compinit

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# autocompletion using arrow keys (based on history)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

##### Enable substring search history (https://github.com/zsh-users/zsh-history-substring-search)
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Set UP and DOWN key bindings for zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^P' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^N' history-substring-search-down

#### Enable zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

#### Enable zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Disable sound errors
setopt NO_BEEP
