return {
  { -- aerial: show the classes and functions in a file, navigate with { and }
    -- (simpler than trouble)
    "stevearc/aerial.nvim",
    enabled = true, --false,
    opts = {
      default_direction = "prefer_right",
    },
    -- Optional dependencies
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("aerial").setup({
        -- optionally use on_attach to set keymaps when aerial has attached to a buffer
        on_attach = function(bufnr)
          -- Jump forwards/backwards with '{' and '}'
          vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
      -- You probably also want to set a keymap to toggle aerial
      vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
    end,
  },
  { -- blink.cmp: best tab completion I've found so far.
    "saghen/blink.cmp",
    enabled = true, --false,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "ribru17/blink-cmp-spell",
    },
    version = "1.3.0",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      signature = { enabled = false }, -- already provided by something else...
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "fallback_to_mappings" },
        ["<S-Tab>"] = { "select_prev", "fallback_to_mappings" },
        ["space"] = { "accept", "fallback" },
        ["<CR>"] = { "accept_and_enter", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true },
        keyword = { range = "full" },

        -- Disable auto brackets
        -- NOTE: some LSPs may add auto brackets themselves anyway
        accept = { auto_brackets = { enabled = false } },
        list = { selection = { preselect = false, auto_insert = true } },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer", "omni", "spell" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          spell = {
            name = "Spell",
            module = "blink-cmp-spell",
            opts = {
              -- EXAMPLE: Only enable source in `@spell` captures, and disable it
              -- in `@nospell` captures.
              enable_in_context = function()
                local curpos = vim.api.nvim_win_get_cursor(0)
                local captures = vim.treesitter.get_captures_at_pos(0, curpos[1] - 1, curpos[2] - 1)
                local in_spell_capture = false
                for _, cap in ipairs(captures) do
                  if cap.capture == "spell" then
                    in_spell_capture = true
                  elseif cap.capture == "nospell" then
                    return false
                  end
                end
                return in_spell_capture
              end,
            },
          },
        },
      },
      --menu = { auto_show = false, },
      fuzzy = {
        implementation = "prefer_rust_with_warning",
        sorts = {
          function(a, b)
            local sort = require("blink.cmp.fuzzy.sort")
            if a.source_id == "spell" and b.source_id == "spell" then
              return sort.label(a, b)
            end
          end,
          -- This is the normal default order, which we fall back to
          "score",
          "kind",
          "label",
        },
      },
    },
    opts_extend = { "sources.default" },
  },
  { -- conform: format buffers with external tools (managed by mason)
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "lua-language-server", "stylua" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "ruff" },
          -- You can customize some of the format options for the filetype (:help conform.format)
          -- rust = { "rustfmt", lsp_format = "fallback" },
          c = { "clang-format" },
          -- Conform will run the first available formatter
          -- javascript = { "prettierd", "prettier", stop_after_first = true },
          toml = { "pyproject_fmt" },
          yaml = { "yamlfmt" },
          css = { "prettier" },
        },
      })
    end,
    keys = {
      {
        "<leader>lc",
        function()
          require("conform").format()
        end,
        desc = "Conform Formatter",
      },
    },
  },
  { -- copilot: AI completions
    "github/copilot.vim",
    enabled = false,
    config = function()
      vim.g.copilot_filetypes = {
        ["*"] = false,
        markdown = true,
        gitcommit = true,
        help = true,
        lua = true,
        vim = true,
        make = true,
        python = true,
        c = true,
        cpp = true,
        rust = true,
        javascript = true,
        typescript = true,
        html = true,
        css = true,
        yaml = true,
        json = true,
        go = true,
        java = true,
        julia = true,
        ruby = true,
        swift = true,
        shell = true,
        bash = true,
        fish = true,
        sql = true,
        fortran = true,
      }
    end,
  },
  { -- lazydev: lsp config for editing vim lua config files
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    enabled = true, --false,
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  { -- nvim-lspconfig: Automatic configs for LSP servers
    "neovim/nvim-lspconfig",
    enabled = true, --false,
  },
  { -- mason: a package manager for LSPs, formatters, linters, and DAPs
    "mason-org/mason.nvim",
    enabled = true, --false,
    config = function()
      require("mason").setup()
    end,
  },
  { -- mason-lsp-config: automatically load LSPs installed with mason where appropriate
    -- (only works for LSPs, not formatters)
    -- automatically loads ruff
    "mason-org/mason-lspconfig.nvim",
    enabled = true, --false,
    lazy = false,
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function(_, opts)
      opts.ensure_installed = { "lua_ls", "pyright", "ruff", "clangd", "bashls" }
      require("mason-lspconfig").setup(opts)
    end,
  },
  { -- mason-tool-installer: always install these formatters/linters
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    enabled = true,
    lazy = false,
    config = function()
      require("mason-tool-installer").setup({
        -- a list of all tools you want to ensure are installed upon
        ensure_installed = {
          -- you can pin a tool to a particular version
          -- { 'golangci-lint', version = 'v1.47.0' },
          -- you can turn off/on auto_update per tool
          -- { 'bash-language-server', auto_update = true },
          -- you can do conditional installing
          -- { 'gopls', condition = function() return not os.execute("go version") end },
          "shellcheck",
          "clang-format",
          "stylua",
          "yamlfmt",
          "isort",
        },
        auto_update = false,
        run_on_start = true,
        debounce_hours = 5, -- at least 5 hours between attempts to install/update
        integrations = {
          ["mason-lspconfig"] = true,
          ["mason-null-ls"] = true,
          ["mason-nvim-dap"] = true,
        },
      })
    end,
  },
  { -- Treesitter: syntax highlighting for any language: auto-installs missing parsers
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    enabled = true, --false,
    config = function(_, opts)
      -- A list of parser names, or "all" (the listed parsers MUST always be installed)
      opts.ensure_installed = {
        "fish",
        "bash",
        "regex",
        "python",
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
      }

      -- Install parsers synchronously (only applied to `ensure_installed`)
      opts.sync_install = false

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      opts.auto_install = true
      opts.ignore_install = { "javascript" }
      opts.highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      }
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
