# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("$HOME/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

# Source modular zsh configuration (XDG-compliant)
for config_file in ~/.config/zsh/*.zsh(N); do
  source "$config_file"
done

# Source machine-local configs (secrets, custom paths)
for config_file in ~/.config/zsh/local/*.zsh(N); do
  source "$config_file"
done
