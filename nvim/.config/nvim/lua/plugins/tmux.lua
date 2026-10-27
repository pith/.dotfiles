-- Ctrl+h/j/k/l across Neovim splits and herdr panes; falls back to
-- vim-tmux-navigator when running under tmux ($TMUX set).
return {
  "aimdevlee/herdr-nvim-nav",
  lazy = false,
  dependencies = {
    {
      "christoomey/vim-tmux-navigator",
      init = function()
        vim.g.tmux_navigator_no_mappings = 1
      end,
    },
  },
  keys = {
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
  config = function()
    require("herdr-nvim-nav").setup()
  end,
}
