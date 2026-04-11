return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>y",
      function()
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
      desc = "Open yazi (cwd)",
    },
  },
  opts = {
    -- Floating window
    floating_window_scaling_factor = 0.9,
    yazi_floating_window_border = "rounded",

    -- Use snacks.picker for grep (already configured)
    integrations = {
      grep_in_directory = "snacks.picker",
      grep_in_selected_files = "snacks.picker",
    },

    -- Remap <c-\> (change_working_directory) to avoid conflict with vim-tmux-navigator
    keymaps = {
      change_working_directory = "<c-w>",
    },
  },
}
