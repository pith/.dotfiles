# dotfiles

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Bootstrap

```sh
git clone git@github.com:pith/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` installs Homebrew, runs `brew bundle` from `brew/.Brewfile`, and symlinks all configs via stow.

**Flags:**
- `--skip-brew` — skip Homebrew install and bundle (useful on re-runs)
- `--force` — overwrite conflicting files when stow detects conflicts

## Update

```sh
make install        # re-run setup.sh
brew bundle --file brew/.Brewfile  # update packages only
stow -R aerospace brew git nvim starship vim wezterm zsh  # re-apply symlinks only
```

## Structure

| Directory    | Config for                        |
|-------------|-----------------------------------|
| `aerospace/` | AeroSpace window manager          |
| `brew/`      | Homebrew Brewfile                 |
| `git/`       | Git config (no personal info)     |
| `nvim/`      | Neovim                            |
| `starship/`  | Starship prompt                   |
| `vim/`       | Vim                               |
| `wezterm/`   | WezTerm terminal                  |
| `zsh/`       | Zsh shell + XDG-compliant configs |

Zsh configs in `zsh/.config/zsh/` use numbered prefixes for load order (`01_path.zsh`, `02_alias.zsh`, etc.).

## Customization

- **Git identity:** create `~/.gitconfig.local` with `[user]` name/email/signingkey (included by `.gitconfig`, not tracked)
- **Machine secrets:** add `zsh/.config/zsh/local/secret_*.zsh` files (gitignored, sourced automatically)

## Development

```sh
make lint           # run pre-commit hooks on all files
make install-hooks  # install pre-commit hooks
make format         # format Lua files with stylua
```

## License

Licensed under the [MIT license](LICENSE).
