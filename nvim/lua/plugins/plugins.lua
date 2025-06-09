return {
  { -- fugitive: provides some addition git tools like blame
    "tpope/vim-fugitive",
    enabled = true,
    keys = {
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
    },
  },
  { -- jupyter-vim: bindings to integrate with a jupyter console
    "jupyter-vim/jupyter-vim",
  },
  { -- vim-autoread: auto-reload files
    "djoshea/vim-autoread",
  },
  { -- which-key: shows reminders for keybindings
    "folke/which-key.nvim",
    event = "VeryLazy",
    enabled = true, --false,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  { -- image: render images in the terminal/editor with kitty
    "3rd/image.nvim",
    opts = {},
    enabled = true, --false,
    --enabled=false,
    config = function()
      require("image").setup({
        backend = "kitty",
        kitty_method = "normal",
        integrations = {
          markdown = {
            enabled = false,
            -- clear_in_insert_mode = true,
            -- download_remote_images = false,
            -- only_render_image_at_cursor = false,
            -- only_render_image_at_cursor_mode = "popup",
            -- floating_windows = true, -- if true, images will be rendered in floating markdown windows
            -- filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
          },
        },
        max_width = 100, -- tweak to preference
        max_height = 14, -- ^
        max_height_window_percentage = math.huge, -- this is necessary for a good experience
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      })
    end,
  },
  { -- Molten: (Experimental) a more deeply integrated jupyter experience.
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    enabled = false,
    dependencies = { "3rd/image.nvim" },
    build = ":UpdateRemotePlugins",
    config = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
    end,
  },
  { -- tokynight: color scheme, slightly modified
    "folke/tokyonight.nvim",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function(_, opts)
      opts.style = "night"
      opts.transparent = true
      opts.styles = {
        sidebars = "dark",
        floats = "dark",
      }
      opts.on_highlights = function(hl, _)
        hl.Folded = { bg = "#002030" }
      end
      opts.on_colors = function(colors)
        colors.bg = "#001020"
      end
      require("tokyonight").setup(opts)
      require("tokyonight").load()
    end,
  },
  { -- fold-preview: fancier folds
    "anuvyklack/fold-preview.nvim",
    enabled = false,
    dependencies = { "anuvyklack/keymap-amend.nvim" }, -- use if you prefer nvim-web-devicons
    config = function()
      require("fold-preview").setup({
        auto = 400,
        default_keybindings = true,
      })
    end,
  },
  { -- onedark: colorscheme
    "navarasu/onedark.nvim",
    lazy = false,
    enabled = false,
    opts = {},
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("onedark").setup({
        transparent = true, -- Show/hide background
        style = "deep",
        code_style = {
          comments = "italic",
          keywords = "bold",
          functions = "none",
          strings = "none",
          variables = "none",
        },
      })
      -- Enable theme
      require("onedark").load()
    end,
  },
  { -- lualine: fancy status line
    "nvim-lualine/lualine.nvim",
    enabled = true, --false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      require("lualine").setup({
        options = {
          extensions = { "quickfix", "fugitive", "trouble", "aerial", "fzf" },
          theme = "onedark",
          tabline = {
            lualine_a = {},
            lualine_b = { "branch" },
            lualine_c = { "filename" },
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
          },
        },
      })
    end,
  },
}
