-- Plugin packages are installed centrally by config.pack.

do -- ibhagwan/fzf-lua
  local actions = require("fzf-lua.actions")

  require("fzf-lua").setup({
    files = {
      fd_opts = [[--color=never --type f --type l --exclude '*.pyc' --exclude .git --no-ignore-vcs]],
    },
    buffers = {
      filename_only = true,
    },
    actions = {
      files = {
        true,
        ["ctrl-q"] = {
          fn = actions.file_sel_to_qf,
          prefix = "select-all",
        },
      },
    },
  })

  vim.keymap.set("n", "<leader>e", "<cmd> FzfLua files<CR>", { desc = "find: fzf files" })
  vim.keymap.set("i", "<C-f>", function()
    require("fzf-lua").complete_path()
  end, { silent = true, desc = "completion: fuzzy path" })
  vim.keymap.set("n", "<leader>f/", "<cmd> FzfLua live_grep<CR>", { desc = "find: live grep" })
  vim.keymap.set("n", "<leader>f#", "<cmd> FzfLua grep_cword<CR>", { desc = "find: cursor" })
  vim.keymap.set("n", "<leader>f&", "<cmd> FzfLua grep<CR>", { desc = "find: filtered grep" })
  vim.keymap.set("n", "<leader>fm", "<cmd> FzfLua <CR>", { desc = "find: meta - search pickers" })
  vim.keymap.set("n", "<leader>ff", "<cmd> FzfLua files<CR>", { desc = "find: fzf files" })
  vim.keymap.set("n", "<leader>fg", "<cmd> FzfLua git_files<CR>", { desc = "find: git files" })
  vim.keymap.set("n", "<leader>fk", "<cmd> FzfLua lsp_references<CR>", { desc = "find: lsp references" })
  vim.keymap.set("n", "<leader>f?", "<cmd> FzfLua search_history<CR>", { desc = "find: previous searches" })
  vim.keymap.set("n", "<leader>fp", "<cmd> FzfLua registers<CR>", { desc = "find: Paste from available registers" })
  vim.keymap.set("n", "<leader>b", "<cmd> FzfLua buffers<CR>", { desc = "find: buffers" })
  vim.keymap.set("n", "<leader>f.", "<cmd> FzfLua resume<CR>", { desc = "find: resume" })
end

do -- echasnovski/mini.files
  local MiniFiles = require("mini.files")
  local show_dotfiles = false
  local filter_show = function()
    return true
  end
  local filter_hide = function(fs_entry)
    return not vim.startswith(fs_entry.name, ".")
  end

  MiniFiles.setup({
    content = {
      filter = filter_hide,
    },
    options = {
      use_as_default_explorer = false,
    },
    windows = {
      preview = true,
      width_focus = 30,
      width_nofocus = 15,
      width_preview = 80,
    },
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local buf = args.data.buf_id

      vim.keymap.set("n", "g~", function()
        local entry = MiniFiles.get_fs_entry() or {}
        if not entry.path then
          vim.notify("Cursor is not on a valid file-system entry")
          return
        end
        vim.fn.chdir(vim.fs.dirname(entry.path))
        vim.notify("cwd: " .. vim.fn.getcwd())
      end, { buffer = buf, desc = "Set cwd to focused directory" })

      vim.keymap.set("n", "g.", function()
        show_dotfiles = not show_dotfiles
        MiniFiles.refresh({
          content = { filter = show_dotfiles and filter_show or filter_hide },
        })
      end, { buffer = buf, desc = "Toggle hidden files" })
    end,
  })

  vim.keymap.set("n", "<leader>pp", function()
    if not MiniFiles.close() then
      local path = vim.api.nvim_buf_get_name(0)
      MiniFiles.open(path ~= "" and path or nil, false)
    end
  end, { desc = "Files: reveal/toggle mini.files" })

  vim.keymap.set("n", "<leader>pc", function()
    if not MiniFiles.close() then
      MiniFiles.open(vim.fn.getcwd(), false)
    end
  end, { desc = "Files: open cwd in mini.files" })
end

do -- stevearc/oil.nvim
  local oil_ready = false
  vim.keymap.set("n", "<leader>E", function()
    if not oil_ready then
      vim.cmd.packadd("oil.nvim")
      require("oil").setup({ default_file_explorer = false })
      oil_ready = true
    end
    vim.cmd("tab Oil %:p:h")
  end, { desc = "Oil: bulk file manipulation" })
end

-- Disabled package/configuration retained for reference:
--[[
{ -- Telescope: alternate file picker to fzf
    "nvim-telescope/telescope.nvim",
    --enabled=true,--false,
    enabled = false,
    --tag = "0.1.8",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        initial_mode = "insert",
        defaults = {
          preview = { ls_short = true },
          mappings = {
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
  }
]]

-- Disabled package/configuration retained for reference:
--[[
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
  }
]]

-- Disabled package/configuration retained for reference:
--[[
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
  }
]]

