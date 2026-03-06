##### History completion ####
# Inspired from https://dev.to/rossijonas/how-to-set-up-history-based-autocompletion-in-zsh-k7o

# AUTOCOMPLETION

# initialize autocompletion
autoload -U compinit && compinit
autoload bashcompinit && bashcompinit

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
local brew_prefix
brew_prefix="$(brew --prefix)"

local plugin="$brew_prefix/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
[[ -f "$plugin" ]] && source "$plugin"

# Set UP and DOWN key bindings for zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^P' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^N' history-substring-search-down

#### Enable zsh-autosuggestions
plugin="$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$plugin" ]] && source "$plugin"

#### Enable zsh-syntax-highlighting
plugin="$brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
[[ -f "$plugin" ]] && source "$plugin"

# Disable sound errors
setopt NO_BEEP
