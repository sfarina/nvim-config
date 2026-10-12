-- Plugin packages are installed centrally by config.pack.

do -- folke/tokyonight.nvim
  require("tokyonight").setup({
    style = "night",
    transparent = true,
    styles = {
      sidebars = "dark",
      floats = "dark",
    },
    on_highlights = function(hl, _)
      hl.Folded = { bg = "#001820", fg = "#00b090" }
      hl.SignColumn = { bg = "#001020", fg = "#00b090" }
    end,
    on_colors = function(colors)
      colors.bg = "#001020"
    end,
  })
  require("tokyonight").load()
end

do -- lewis6991/gitsigns.nvim
  require("gitsigns").setup({
    signs = {
      add = { text = "+" },
      change = { text = "∆" },
      delete = { text = "-" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
      untracked = { text = "|" },
    },
    signs_staged = {
      add = { text = "+" },
      change = { text = "∆" },
      delete = { text = "-" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
      untracked = { text = "|" },
    },
    signs_staged_enable = true,
    current_line_blame = false,
    preview_config = {
      relative = "editor",
      anchor = "NE",
      row = 1,
      col = vim.o.columns - 2,
      style = "minimal",
      border = "rounded",
    },
    diff_opts = { linematch = false },
  })

  -- When Neovim is launched with a file argument, BufEnter may have already
  -- fired before Gitsigns finishes setup. Attach the initial buffer explicitly
  -- while retaining Gitsigns' normal automatic attachment for later buffers.
  local initial_buf = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(initial_buf) then
      require("gitsigns").attach({ bufnr = initial_buf, trigger = "setup" })
    end
  end)

  vim.keymap.set("n", "<leader>gv", "<cmd>Gitsigns diffthis HEAD<cr>", { desc = "Git vertical diff HEAD" })
  -- { "<leader>gV", "<cmd>Gitsigns diffthis main<cr>", desc = "Git vertical diff main" },
  vim.keymap.set("n", "<leader>gV", function()
    local merge_base = vim.trim(vim.fn.system("git merge-base HEAD main"))
    if vim.v.shell_error ~= 0 or merge_base == "" then
      merge_base = vim.trim(vim.fn.system("git merge-base HEAD master"))
    end
    vim.cmd("Gitsigns diffthis " .. merge_base)
  end, { desc = "Git vertical diff PR merge-base" })
  vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame<cr>", { desc = "Git Blame" })
  vim.keymap.set("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Git Blame lines" })
  vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<cr>", { desc = "Git Preview hunk (inline)" })
  vim.keymap.set("n", "<leader>gP", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Git Preview hunk" })
  -- vim.keymap.set("n", "<leader>gj", "<cmd>Gitsigns nav_hunk next<cr>", {desc = "Git next hunk" })
  -- vim.keymap.set("n", "<leader>gk", "<cmd>Gitsigns nav_hunk prev<cr>", {desc = "Git prev hunk" })
  vim.keymap.set("n", "<leader>gg", "<cmd>Gitsigns setqflist all<cr>", { desc = "Git good (show all changes)" })
  vim.keymap.set("n", "]c", function()
    if vim.wo.diff then
      vim.cmd.normal({ "]c", bang = true })
    else
      vim.cmd("silent! Gitsigns nav_hunk next")
      -- vim.cmd("silent! Gitsigns preview_hunk")
    end
  end, { desc = "next git hunk" })
  vim.keymap.set("n", "[c", function()
    if vim.wo.diff then
      vim.cmd.normal({ "[c", bang = true })
    else
      vim.cmd("silent! Gitsigns nav_hunk prev")
      -- vim.cmd("silent! Gitsigns preview_hunk")
    end
  end, { desc = "next git hunk" })
end

do -- luarocks/hererocks
end

do -- folke/which-key.nvim
  vim.keymap.set("n", "<leader>?", function()
    require("which-key").show({ global = false })
  end, { desc = "Buffer Local Keymaps (which-key)" })
end

do -- 3rd/image.nvim
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
    max_height = 25, -- ^
    max_height_window_percentage = math.huge, -- this is necessary for a good experience
    max_width_window_percentage = math.huge,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
  })
end

-- Disabled package/configuration retained for reference:
--[[
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
  }
]]

do -- romgrk/barbar.nvim },
  require("barbar").setup({
    auto_hide = false,
    exclude_ft = { "qf" },
    -- hide = { extensions = true },
    insert_at_end = true,
    icons = {
      -- Configure the base icons on the bufferline.
      -- Valid options to display the buffer index and -number are `true`, 'superscript' and 'subscript'
      buffer_index = false,
      buffer_number = false,
      button = "×",
      -- Enables / disables diagnostic symbols
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = { enabled = true, icon = "" },
        [vim.diagnostic.severity.WARN] = { enabled = true, icon = "" },
        [vim.diagnostic.severity.INFO] = { enabled = false },
        [vim.diagnostic.severity.HINT] = { enabled = false },
      },
      gitsigns = {
        added = { enabled = true, icon = "+" },
        changed = { enabled = true, icon = "∆" },
        deleted = { enabled = true, icon = "-" },
      },
      filetype = {
        -- Sets the icon's highlight group.
        -- If false, will use nvim-web-devicons colors
        custom_colors = false,

        -- Requires `nvim-web-devicons` if `true`
        enabled = true,
      },
      separator = { left = "▎", right = "" },

      -- If true, add an additional separator at the end of the buffer list
      separator_at_end = true,

      -- Configure the icons on the bufferline when modified or pinned.
      -- Supports all the base icon options.
      modified = { button = "●" },

      pinned = { button = "", filename = true },

      -- Use a preconfigured buffer appearance— can be 'default', 'powerline', or 'slanted'
      preset = "default",

      -- Configure the icons on the bufferline based on the visibility of a buffer.
      -- Supports all the base icon options, plus `modified` and `pinned`.
      alternate = { filetype = { enabled = false } },
      current = { buffer_index = false },
      inactive = { button = "×" },
      visible = { modified = { buffer_number = false } },
    },
  })
end

do -- nvim-lualine/lualine.nvim
  local function macro_register()
    local recording_register = vim.fn.reg_recording()
    if recording_register ~= "" then
      return "@" .. recording_register
    end
    return ""
  end
  require("lualine").setup({
    extensions = { "quickfix", "aerial", "fzf" },
    sections = {
      lualine_a = { macro_register, "mode" },
      lualine_b = { "branch" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "lsp_status" },
      lualine_y = { "filetype" },
      lualine_z = { { "location", separator = "|" }, "progress", "tabs" },
    },
    options = {
      theme = "iceberg_dark",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      -- theme = "codedark",
      -- theme = "tomorrow_night",
    },
  })
end

-- Disabled package/configuration retained for reference:
--[[
{ -- bufferline: replace tabs with buffers
    "akinsho/bufferline.nvim",
    enabled = false,
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      vim.opt.termguicolors = true
      require("bufferline").setup({})
    end,
  }
]]

do -- axkirillov/unified.nvim
  require("unified").setup({})
end
