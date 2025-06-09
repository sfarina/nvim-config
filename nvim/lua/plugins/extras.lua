return {
  { -- noice: Highly experimental plugin that completely replaces the UI
    -- for messages, cmdline and the popupmenu
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          -- bottom_search = false, -- use a classic bottom cmdline for search
          -- command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = true, -- add a border to hover docs and signature help
        },
      })
    end,
  },
  { -- Snacks: like popcorn at a movie, they just make life a tiny bit better
    "folke/snacks.nvim",
    priority = 1000,
    enabled = true, --false,
    -- tag="stable",
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      explorer = { enabled = false, replace_netrw = false },
      indent = { enabled = true, animate = { duration = { total = 200 } } },
      input = { enabled = true }, -- not sure what this does.
      image = {
        enabled = true,
        -- render the image inline in the buffer
        -- if your env doesn't support unicode placeholders, this will be disabled
        -- takes precedence over `opts.float` on supported terminals
        inline = true,
        -- render the image in a floating window
        -- only used if `opts.inline` is disabled
        float = false,
      },
      picker = { enabled = false },
      lazygit = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      rename = { enabled = true },
      scope = { enabled = true },
      styles = { enabled = true },
      scroll = { enabled = false },
      terminal = { enabled = true },
      statuscolumn = { enabled = false },
      words = { enabled = true },

      -- new to me
      animate = { enabled = true },
      layout = { enabled = true },
      scratch = { enabled = true },
      toggle = { enabled = true },
      dim = { enabled = true },
      win = { enabled = true },
      zen = {
        enabled = true,
        toggles = {
          dim = true,
          git_signs = false,
          mini_diff_signs = false,
          diagnostics = false,
          inlay_hints = false,
        },
        show = {
          statusline = false, -- can only be shown when using the global statusline
          tabline = false,
        },
      },
    },
    config = function(_, opts)
      local snacks = require("snacks")
      snacks.setup(opts)
    end,
    keys = {
      {
        "<leader>gl",
        function()
          Snacks.lazygit()
        end,
        desc = "Git (lazy)",
      },
      {
        "<leader>vh",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "show error history",
      },
      {
        "<leader>sz",
        function()
          Snacks.zen()
        end,
        desc = "Zen mode",
      },
      {
        "<leader>si",
        function()
          if Snacks.indent.enabled then
            Snacks.indent.disable()
          else
            Snacks.indent.enable()
          end
        end,
        desc = "toggle indentation guides",
      },
      {
        "<leader>sd",
        function()
          if Snacks.dim.enabled then
            Snacks.dim.disable()
          else
            Snacks.dim()
          end
        end,
        desc = "toggle scope dimming",
      },
      {
        "<leader>t",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle Snacks terminal",
      },
      {
        "<leader>st",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "Toggle Snacks terminal",
      },
      {
        "<leader>sn",
        function()
          Snacks.terminal.open()
        end,
        desc = "New Snacks terminal",
      },
      {
        "<leader>.",
        function()
          Snacks.scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          Snacks.scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
    },
  },
}
