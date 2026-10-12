-- Plugin packages are installed centrally by config.pack.

-- Disabled package/configuration retained for reference:
--[[
{ -- code companion, :magic: future :magic:
    "olimorris/codecompanion.nvim",
    enabled = false,
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  }
]]

-- Disabled package/configuration retained for reference:
--[[
{ -- blink-copilot: add copilot completions to blink-cmp
    "fang2hou/blink-copilot",
    enabled = false,
  }
]]

if vim.env.GITHUB_COPILOT_ENABLE == "1" then
  do -- zbirenbaum/copilot.lua
    require("copilot").setup({
      max_suggestions = 1,
      server_opts_overrides = {
        settings = {
          advanced = {
            listCount = 1, -- #completions for panel
            inlineSuggestCount = 1, -- #completions for getCompletions
          },
          telemetry = {
            -- do not send telemetry data
            enabled = false,
            telemetryLevel = "off",
          },
        },
      },
      panel = {
        enabled = false, -- enable the suggestion panel
        auto_refresh = false, -- set true to refresh on typing
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          -- refresh = "gr",
          open = "<C-CR>",
        },
        layout = {
          position = "right", -- can be top|left|right|bottom
          ratio = 0.4, -- how much of the screen the panel occupies
        },
      },
      suggestion = {
        enabled = true, -- enable inline ghost suggestions
        auto_trigger = true, -- automatically trigger suggestions when typing
        hide_during_completion = true, -- hides ghost text while other completion menus are open
        debounce = 75,
        trigger_on_accept = true,
        keymap = {
          accept = "<C-l>",
          accept_word = "C-w>",
          accept_line = "C-o",
          next = "<C-j>",
          prev = "<C-k>",
          dismiss = "<C-h>",
        },
      },
      filetypes = {
        markdown = true,
        quarto = true,
        dosini = true,
        help = true,
        python = true,
        lua = true,
        rust = true,
        cpp = true,
        c = true,
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
        make = true,
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            -- disable for .env files
            return false
          end
          return true
        end,
        bash = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            -- disable for .env files
            return false
          end
          return true
        end,
        fish = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            -- disable for .env files
            return false
          end
          return true
        end,
        -- fish = true,
        sql = true,
        fortran = true,
        gitcommit = true, -- enable in gitcommit
        ["*"] = false, -- disable for all other filetypes
      },
      auth_provider_url = vim.env.GITHUB_COPILOT_AUTH_PROVIDER,
    })

    vim.keymap.set("n", "<leader>cp", "<cmd>Copilot panel<CR>", { desc = "Copilot Panel" })
    vim.keymap.set("n", "<leader>cs", "<cmd>Copilot suggestion<CR>", { desc = "Copilot Suggestion" })
    vim.keymap.set("n", "<leader>ca", "<cmd>Copilot auth<CR>", { desc = "Copilot Auth" })
    vim.keymap.set("n", "<leader>cd", "<cmd>Copilot disable<CR>", { desc = "Copilot Disable" })
    vim.keymap.set("n", "<leader>ce", "<cmd>Copilot enable<CR>", { desc = "Copilot Enable" })
  end
end
