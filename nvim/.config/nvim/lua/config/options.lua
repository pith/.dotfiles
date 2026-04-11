-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Point yazi at a neovim-specific config that disables graphical image protocols.
-- WezTerm's env vars (TERM_PROGRAM=WezTerm) make yazi attempt Kitty/Sixel inside
-- neovim's terminal emulator (libvterm), which can't handle them — the escape
-- sequences leak as keypresses (triggering rename). Standalone yazi is unaffected.
vim.env.YAZI_CONFIG_HOME = vim.fn.expand("~/.config/yazi-nvim")
