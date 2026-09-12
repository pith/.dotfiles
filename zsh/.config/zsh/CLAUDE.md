# zsh/.config/zsh/ naming

- `01_*.zsh` - System configuration (PATH)
- `02_*.zsh` - Shell behavior (aliases, completion, prompt)
- `03_*.zsh` - Tool-specific configs
- `local/` - Machine-local secrets (gitignored, not in git)

Numbered prefixes control load order — don't renumber a file without checking what depends on it loading before/after its neighbors.
