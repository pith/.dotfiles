# Source modular zsh configuration (XDG-compliant)
for config_file in ~/.config/zsh/*.zsh(N); do
  source "$config_file"
done

# Source machine-local configs (secrets, custom paths)
for config_file in ~/.config/zsh/local/*.zsh(N); do
  source "$config_file"
done
