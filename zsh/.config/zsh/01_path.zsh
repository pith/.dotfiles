add_to_path() {
  if [[ ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

add_to_path "/opt/homebrew/bin"
export EDITOR=nvim
export VISUAL=nvim
add_to_path "$HOME/bin"
add_to_path "$HOME/.local/bin"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
add_to_path "$HOME/.rd/bin"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
