return {
  { -- fzf: fuzzy finder. use for finding all manner of things.
    "ibhagwan/fzf-lua",
    enabled = true,
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd> FzfLua files<CR>", desc = "find: fzf files" },
      { "<leader>f/", "<cmd> FzfLua live_grep<CR>", desc = "find: live grep" },
      { "<leader>f#", "<cmd> FzfLua grep_cword<CR>", desc = "find: cursor" },
      { "<leader>f&", "<cmd> FzfLua grep<CR>", desc = "find: filtered grep" },
      { "<leader>fm", "<cmd> FzfLua <CR>", desc = "find: meta - search pickers" },
      { "<leader>ff", "<cmd> FzfLua files<CR>", desc = "find: fzf files" },
      { "<leader>fg", "<cmd> FzfLua git_files<CR>", desc = "find: git files" },
      { "<leader>fk", "<cmd> FzfLua lsp_references<CR>", desc = "find: lsp references" },
      { "<leader>f?", "<cmd> FzfLua search_history<CR>", desc = "find: previous searches" },
      { "<leader>fp", "<cmd> FzfLua registers<CR>", desc = "find: Paste from available registers" },
      { "<leader>fb", "<cmd> FzfLua buffers<CR>", desc = "find: buffers" },
    },
    config = function()
      local conf = require("fzf-lua.config")
      local actions = require("trouble.sources.fzf").actions
      conf.defaults.actions.files["ctrl-x"] = actions.open_all
    end,
  },
  { -- neo-tree: a file tree (and buffer, and git status) browswer in a side float
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true, --false,
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      --"3rd/image.nvim"
    },
    lazy = false, -- neo-tree will lazily load itself extremely slowly. preload it because I like to use it.
    ---@module "neo-tree"
    ---@type neotree.Config?
    opts = {},
    config = function()
      require("neo-tree").setup({
        close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
        enable_cursor_hijack = true, -- If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree.
        follow_current_file = true,
        window = {
          mappings = {
            ["<space>"] = nil,
            ["l"] = "toggle_node",
            ["P"] = {
              "toggle_preview",
              config = {
                use_float = true,
                use_image_nvim = true,
                -- title = 'Neo-tree Preview',
              },
            },
          },
        },
        filesystem = {
          window = {
            mappings = {
              ["h"] = "navigate_up",
            },
          },
        },
      })
    end,
    keys = {
      { "<leader><space>", "<cmd>Neotree reveal<CR>", desc = "neo-tree files reveal" },
      -- {"<leader>L", "<cmd>Neotree<CR>", desc="neo-tree files"},
      { "<leader>b", "<cmd>Neotree source=buffers<CR>", desc = "neo-tree buffers" },
      { "<leader>gs", "<cmd>Neotree source=git_status<CR>", desc = "neo-tree git status" },
      -- {"<leader>A", "<cmd>Neotree source=document_symbols<CR>", desc="neo-tree LSP symbols"},
    },
  },
  { -- oil: edit (the names of) files in a folder
    "stevearc/oil.nvim",
    enabled = true, --false,
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    config = function()
      require("oil").setup({
        default_file_explorer = false,
      })
    end,
    lazy = false,
    keys = { { "<leader>E", "<cmd>tab Oil %:p:h<CR>" } },
  },
  { -- Telescope: alternate file picker to fzf
    "nvim-telescope/telescope.nvim",
    --enabled=true,--false,
    enabled = false,
    --tag = "0.1.8",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local open_with_trouble = require("trouble.sources.telescope").open
      local telescope = require("telescope")
      telescope.setup({
        initial_mode = "insert",
        defaults = {
          preview = { ls_short = true },
          mappings = {
            n = { ["<C-S-t>"] = open_with_trouble },
            i = { ["<C-S-t>"] = open_with_trouble },
          },
        },
      })
    end,
    keys = {
      { "<leader>e", "<cmd> Telescope find_files<CR>", desc = "find files" },
      { "<leader>f/", "<cmd> Telescope live_grep<CR>", desc = "live grep" },
      { "<leader>f#", "<cmd> Telescope grep_string<CR>", desc = "grep string under cursor" },
      { "<leader>fm", "<cmd> Telescope <CR>", desc = "find meta - search pickers" },
      { "<leader>fg", "<cmd> Telescope git_files<CR>", desc = "git files" },
      { "<leader>fk", "<cmd> Telescope lsp_references<CR>", desc = "lsp references" },
      { "<leader>f?", "<cmd> Telescope search_history<CR>", desc = "lsp search history" },
      { "<leader>fp", "<cmd> Telescope registers<CR>", desc = "Search registers" },
      { "<leader>fb", "<cmd> Telescope buffers<CR>", desc = "buffers" },
    },
  },
  { -- telescope-fzf-native: better / faster fuzzy find for telescope
    "nvim-telescope/telescope-fzf-native.nvim",
    --enabled=true,--false,
    enabled = false,
    build = "make",
    config = function()
      require("telescope").setup({
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
        },
      })
    end,
  },
  { -- telescope-file-browser: file browser in telescope
    "nvim-telescope/telescope-file-browser.nvim",
    enabled = false,
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      local fb_actions = require("telescope._extensions.file_browser.actions")
      require("telescope").setup({
        extensions = {
          file_browser = {
            -- theme = "ivy",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            preview = { ls_short = true },
            display_stat = false,
            initial_mode = "normal",
            --depth = 2,
            --auto_depth = true,
            --
            mappings = {
              ["n"] = {
                ["g"] = nil,
                ["h"] = fb_actions.goto_parent_dir,
                ["l"] = fb_actions.change_cwd,
                ["v"] = fb_actions.toggle_hidden,
              },
            },
            --
          },
        },
      })
      require("telescope").load_extension("file_browser")
    end,
  },
  { -- Trouble: quickly navigate between many locations.
    -- has excellent tie ins with LSP
    -- like quickfix on steroids
    -- open any fzf results with ctrl-x
    "folke/trouble.nvim",
    lazy = false,
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics open focus=true <cr>", desc = "Diagnostics (Trouble)" },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics open focus=true filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      { "<leader>cs", "<cmd>Trouble symbols open focus=true<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>cl",
        "<cmd>Trouble lsp open focus=true win.position=right win.size.width=60<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      { "<leader>cr", "<cmd>Trouble lsp_references open focus=true<cr>", desc = "LSP References (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist open focus=true<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist open focus=true<cr>", desc = "Quickfix List (Trouble)" },
    },
    opts = {
      auto_refresh = false, -- auto refresh when open
    },
    config = function(_, opts)
      require("trouble").setup(opts)
    end,
  },
}
