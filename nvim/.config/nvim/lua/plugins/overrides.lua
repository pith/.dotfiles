return {
  {
    -- copilot.lua runs node outside the shell, so it doesn't inherit the PATH
    -- that mise sets up. Point it at the mise-managed node binary directly.
    "zbirenbaum/copilot.lua",
    opts = {
      copilot_node_command = vim.fn.expand("~/.local/share/mise/installs/node/lts/bin/node"),
    },
  },
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
        sign = true,
        width = "block",
        right_pad = 1,
        style = "full",
        border = "thin",
      },
      heading = {
        sign = true,
        icons = {},
      },
      checkbox = { enabled = true },
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
                maxTsServerMemory = 12288,
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
        lua = { "stylua" },
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
        -- Prettier 4.x (used in this monorepo) dropped --stdin-filepath and all stdin support.
        -- Conform's built-in prettier formatter relies on stdin piping, which no longer works.
        -- Override to use --write on the actual file path instead.
        prettier = {
          require_cwd = true,
          stdin = false,
          args = { "--write", "$FILENAME" },
          -- Skip package.json: Prettier sorts its fields into a canonical order, which
          -- conflicts with intentional field ordering in package.json files.
          condition = function(self, ctx)
            return vim.fs.basename(ctx.filename) ~= "package.json"
          end,
        },
      },
    },
  },
}
