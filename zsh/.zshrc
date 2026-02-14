# Source all .zsh files from the ~/.zsh directory
for config_file in ~/dotfiles/zsh-config/*.zsh; do
  source "$config_file"
done

