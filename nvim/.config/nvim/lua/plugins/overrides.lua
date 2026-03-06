return {
  {
    "catppuccin/nvim",
    opts = {
      transparent_background = true,
      integrations = {
        render_markdown = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      code = {
        style = "full",
        border = "thin",
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          files = { hidden = true },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              tsserver = {
                maxTsServerMemory = 8192,
              },
            },
          },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
      },
      formatters = {
        prettier = {
          require_cwd = true,
        },
      },
    },
  },
}
