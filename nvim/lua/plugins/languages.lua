do -- stevearc/aerial.nvim
  require("aerial").setup({
    default_direction = "prefer_right",
    backends = { "treesitter", "lsp", "markdown", "man" },
    highlight_on_jump = true,
    close_on_select = false,
    -- optionally use on_attach to set keymaps when aerial has attached to a buffer
    on_attach = function(bufnr)
      -- Jump forwards/backwards with '{' and '}'
      vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
      vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
    end,
  })
end

do -- nvim-mini/mini.snippets + nvim-mini/mini.completion
  local snippets = require("mini.snippets")
  local gen_loader = snippets.gen_loader

  snippets.setup({
    snippets = {
      -- friendly-snippets is already installed as a runtime package.
      gen_loader.from_runtime("*.json"),
      gen_loader.from_runtime("*.lua"),
    },
  })

  -- Keep the native popup from covering a large portion of the buffer.
  -- Neovim automatically flips it above the cursor when needed.
  vim.opt.pumheight = 12
  vim.opt.pummaxwidth = 100
  vim.opt.pumborder = "rounded"

  require("mini.completion").setup({
    -- Signature help is requested explicitly with <C-s> below.
    delay = { completion = 75, info = 100, signature = 10 ^ 7 },
    -- Don't automatically fall back to buffer/text completion. This keeps
    -- auto-popup useful in prose-heavy buffers such as Markdown.
    fallback_action = function() end,
    window = {
      info = { border = "rounded" },
      signature = { border = "rounded" },
    },
    lsp_completion = {
      -- Fuzzy filtering is the closest built-in equivalent to Blink's fuzzy list.
      process_items = function(items, base)
        return MiniCompletion.default_process_items(items, base, {
          filtersort = "fuzzy",
          -- Text and snippet candidates are noisy for automatic completion;
          -- keep semantic LSP completion kinds available.
          kind_priority = { Text = -1, Snippet = -1 },
        })
      end,
    },
  })

  local function pum_key(key)
    return vim.api.nvim_replace_termcodes(key, true, false, true)
  end

  vim.keymap.set("i", "<Tab>", function()
    return vim.fn.pumvisible() == 1 and pum_key("<C-n>") or pum_key("<Tab>")
  end, { expr = true, desc = "completion: next or tab" })

  vim.keymap.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and pum_key("<C-p>") or pum_key("<S-Tab>")
  end, { expr = true, desc = "completion: previous or shift-tab" })

  local function accept_or(key)
    if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
      return pum_key("<C-y>")
    end
    return pum_key(key)
  end

  vim.keymap.set("i", "<CR>", function()
    return accept_or("<CR>")
  end, { expr = true, desc = "completion: accept or enter" })
end

do -- stevearc/conform.nvim
  require("conform").setup({
    formatters = {
      jq = {
        command = "jq",
        args = { "--indent", "2", "." },
      },
    },
    formatters_by_ft = {
      lua = { "lua-language-server", "stylua" },
      -- Conform will run multiple formatters sequentially
      python = { "isort", "ruff" },
      -- You can customize some of the format options for the filetype (:help conform.format)
      -- rust = { "rustfmt", lsp_format = "fallback" },
      c = { "clang-format" },
      -- Conform will run the first available formatter
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
      toml = { "taplo" },
      markdown = { "mdformat" },
      yaml = { "yamlfmt" },
      css = { "prettier" },
      json = { "jq" },
      bash = { "shfmt" },
      -- gitcommit = { "commitlint" },
    },
  })

  vim.keymap.set("n", "<leader>lc", function()
    require("conform").format()
  end, { desc = "Conform Formatter" })
end

do -- folke/lazydev.nvim
  require("lazydev").setup({
    library = {
      -- See the configuration section for more details
      -- Load luvit types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    },
  })
end

do -- mason-org/mason.nvim
  require("mason").setup()
end

do -- mason-org/mason-lspconfig.nvim
  require("mason-lspconfig").setup({
    ensure_installed = {
      -- "basedpyright",
      "bashls",
      "fish_lsp",
      "lua_ls",
      "ansiblels",
      "ruff",
      "tombi",
      "ty",
      "typos_lsp",
      "clangd",
    },
    automatic_enable = {
      exclude = { "ansiblels" },
    },
  })
end

do -- WhoIsSethDaniel/mason-tool-installer.nvim
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
      "ansible-lint",
      "clang-format",
      "cortex-debug",
      "stylua",
      "mdformat",
      "yamlfmt",
      "isort",
      "commitlint",
    },
    auto_update = false,
    run_on_start = false,
    debounce_hours = 5, -- at least 5 hours between attempts to install/update
    integrations = {
      ["mason-lspconfig"] = true,
      ["mason-null-ls"] = true,
      ["mason-nvim-dap"] = true,
    },
  })
end

do -- mfussenegger/nvim-lint
  require("lint").linters_by_ft = {
    gitcommit = { "commitlint" },
  }

  vim.keymap.set("n", "<leader>ll", function()
    local linters = vim.b.ansible_enabled and { "ansible_lint" } or nil
    require("lint").try_lint(linters)
  end, { desc = "nvim-lint this file" })
end

do -- nvim-treesitter/nvim-treesitter
  require("nvim-treesitter").setup()

  -- Install the parsers used by the native Tree-sitter setup. JavaScript is
  -- intentionally omitted.
  require("nvim-treesitter").install({
    "fish",
    "bash",
    "regex",
    "python",
    "c",
    "csv",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "xml",
    "make",
  })
end

do -- nvim-treesitter/nvim-treesitter-context
  require("treesitter-context").setup({
    enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    multiwindow = false, -- Enable multiwindow support.
    max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
    min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    line_numbers = true,
    multiline_threshold = 7, -- Maximum number of lines to show for a single context
    trim_scope = "inner", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
    -- Separator between context and content. Should be a single character string, like '-'.
    -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    -- separator = ".",
    zindex = 20, -- The Z-index of the context window
    on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
  })

  vim.keymap.set("n", "<leader>sx", function()
    vim.cmd("TSContext toggle")
  end, { desc = "Toggle tressitter context" })
end

do -- nvim-treesitter/nvim-treesitter-textobjects
  -- Disable entire built-in ftplugin mappings to avoid conflicts.
  -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
  vim.g.no_plugin_maps = true

  -- Or, disable per filetype (add as you like)
  -- vim.g.no_python_maps = true
  -- vim.g.no_ruby_maps = true
  -- vim.g.no_rust_maps = true
  -- vim.g.no_go_maps = true

  require("nvim-treesitter-textobjects").setup()
end

require("config.dap")
