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

# Catppuccin Mocha theme for zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6c7086'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#fab387,italic'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[negation]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#89dceb'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#89dceb'

# Disable sound errors
setopt NO_BEEP
