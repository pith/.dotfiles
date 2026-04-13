# dotfiles

Personal macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Bootstrap

Run once on a fresh machine:

```sh
git clone git@github.com:pith/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Homebrew, initializes git submodules, runs `brew bundle` from `brew/.Brewfile`, symlinks all configs via stow, installs TPM plugins, and prompts for git identity (`~/.gitconfig.local`).

**Flags:**
- `--skip-brew` — skip Homebrew install and bundle (useful when brew is already set up)
- `--force` — overwrite conflicting files when stow detects conflicts

## Sync

Keep dotfiles in sync with remote after pulling changes:

```sh
./sync.sh
# or
make sync
```

`sync.sh` stashes any WIP, pulls with `--ff-only`, restores the stash, updates brew packages, and restows all symlinks. Safe to run non-interactively.

**Flags:**
- `--skip-brew` — skip Homebrew bundle update

## Structure

| Directory    | Config for                        |
|-------------|-----------------------------------|
| `aerospace/` | AeroSpace window manager          |
| `brew/`      | Homebrew Brewfile                 |
| `git/`       | Git config (no personal info)     |
| `nvim/`      | Neovim                            |
| `starship/`  | Starship prompt                   |
| `vim/`       | Vim                               |
| `tmux/`      | Tmux + TPM + Catppuccin theme     |
| `wezterm/`   | WezTerm terminal                  |
| `zsh/`       | Zsh shell + XDG-compliant configs |

Zsh configs in `zsh/.config/zsh/` use numbered prefixes for load order (`01_path.zsh`, `02_alias.zsh`, etc.).

Tmux plugins are managed via two mechanisms:
- **Git submodules** — [TPM](https://github.com/tmux-plugins/tpm) (`tmux/.tmux/plugins/tpm`) and the [Catppuccin theme](https://github.com/catppuccin/tmux) (`tmux/.config/tmux/plugins/catppuccin/tmux`)
- **TPM** — remaining plugins (`tmux-sensible`, `vim-tmux-navigator`) installed at runtime via `~/.tmux/plugins/tpm/bin/install_plugins`

## Customization

- **Git identity:** create `~/.gitconfig.local` with `[user]` name/email/signingkey (included by `.gitconfig`, not tracked)
- **Machine secrets:** add `zsh/.config/zsh/local/secret_*.zsh` files (gitignored, sourced automatically)

## Development

```sh
make lint           # run pre-commit hooks on all files
make format         # format Lua files with stylua
```

## License

Licensed under the [MIT license](LICENSE).
