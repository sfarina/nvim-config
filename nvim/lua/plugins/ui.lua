-- Plugin packages are installed centrally by config.pack.
--

do -- folke/snacks.nvim
  require("snacks").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false, replace_netrw = false },
    indent = {
      enabled = false,
      -- only_scope = true,
      -- only_current = true,
      animate = { enabled = false, style = "down", duration = { total = 500 } },
    },
    input = { enabled = false }, -- not sure what this does.
    image = {
      enabled = false,
      -- render the image inline in the buffer
      -- if your env doesn't support unicode placeholders, this will be disabled
      -- takes precedence over `opts.float` on supported terminals
      inline = false,
      -- render the image in a floating window
      -- only used if `opts.inline` is disabled
      float = false,
    },
    picker = { enabled = false },
    lazygit = { enabled = true },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    rename = { enabled = false },
    scope = { enabled = false },
    styles = { enabled = false },
    scroll = { enabled = false },
    terminal = { enabled = false },
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign", "fold" },
      right = { "git" },
      folds = {
        open = false, -- show open fold icons
        git_hl = false, -- use Git Signs hl for fold icons
      },
      git = {
        -- patterns to match Git signs
        patterns = { "GitSign" },
      },
    },
    words = { enabled = false },
    animate = { enabled = false },
    layout = { enabled = false },
    scratch = { enabled = false },
    toggle = { enabled = false },
    dim = { enabled = false },
    win = { enabled = false },
    zen = { enabled = false },
  })

  vim.keymap.set("n", "<leader>gl", function()
    Snacks.lazygit()
  end, { desc = "Git (lazy)" })
end

do -- hat0uma/csvview.nvim
  local csvview = require("csvview")
  csvview.setup({
    parser = {
      delimiter = {
        ft = { csv = "," },
      },
      comments = { "#", "//" },
    },
    view = {
      display_mode = "border",
      header_lnum = 1,
      sticky_header = {
        enabled = true,
        separator = "─",
      },
    },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
  })

  local csvview_group = vim.api.nvim_create_augroup("config-csvview", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = csvview_group,
    pattern = "csv",
    callback = function(args)
      csvview.enable(args.buf)
    end,
  })

  -- The command-line buffer can finish filetype detection during startup.
  vim.api.nvim_create_autocmd("VimEnter", {
    group = csvview_group,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].filetype == "csv" then
        csvview.enable(bufnr)
      end
    end,
  })

  vim.keymap.set("n", "<leader>cv", function()
    vim.cmd.CsvViewToggle()
  end, { desc = "CSV View Toggle" })

  vim.keymap.set("n", "<leader>cV", function()
    vim.cmd.CsvViewEnable("delimiter=,")
  end, { desc = "CSV View Enable (comma)" })
end

do -- jq-playground
  -- start the playground
  require("jq-playground").setup({})
  vim.keymap.set("n", "<leader>jq", vim.cmd.JqPlayground)

  -- when in the query window, run the jq query
  -- vim.keymap.set("n", "R", "<Plug>(JqPlaygroundRunQuery)")
end

do -- nvzone/minty
  require("minty").setup({})
end

do -- highlight colors
  vim.opt.termguicolors = true

  require("nvim-highlight-colors").setup({})
end
