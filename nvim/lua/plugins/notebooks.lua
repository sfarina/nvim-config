-- Plugin packages are installed centrally by config.pack.

-- Disabled package/configuration retained for reference:
--[[
{ -- jupyter-vim: bindings to integrate with a jupyter console
    -- note: this requires whatever python is configured for nvim to have
    -- the nvim python package installed.
    -- this adds 300 ms to startup... it's not worth it.
    "jupyter-vim/jupyter-vim",
    enabled = false,
    lazy = false,
    keys = {
      -- {"<leader>mc", function() vim.cmd("Lazy load jupyter-vim") end, desc = "start jupytervim Console bindings" },
      {
        "<leader><CR>",
        function()
          vim.cmd("JupyterSendCell")
        end,
        desc = "Execute Jupter Cell with jupyter-vim",
      },
    },
  }
]]

do -- benlubas/molten-nvim
  vim.g.molten_image_location = "float"
  vim.g.molten_image_provider = "image.nvim"
  vim.g.molten_output_win_max_height = 30
  vim.g.molten_virt_text_max_lines = 18
  vim.g.molten_auto_open_output = true

  -- optional, I like wrapping. works for virt text and the output window
  vim.g.molten_wrap_output = true

  -- Output as virtual text. Allows outputs to always be shown, works with images, but can
  -- be buggy with longer images
  vim.g.molten_virt_text_output = true

  -- this will make it so the output shows up below the \`\`\` cell delimiter
  vim.g.molten_virt_lines_off_by_1 = true

  -- How often (in ms) we poll the kernel for updates.
  -- Determines how quickly the ui will update, if you want a snappier experience, you can set this to 150 or 200
  vim.g.molten_tick_rate = 500
  vim.cmd("highlight clear MoltenCell")

  vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "evaluate operator" })
  vim.keymap.set("n", "<leader>mo", ":noautocmd MoltenEnterOutput<CR>", { desc = "open output window", silent = true })
  vim.keymap.set(
    "n",
    "<leader>mO",
    ":noautocmd MoltenImagePopup<CR>",
    { desc = "open external output popup", silent = true }
  )
  vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>", { desc = "re-eval cell", silent = true })
  -- { "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", desc = "execute visual selection", silent = true },
  vim.keymap.set("n", "<leader>mx", ":MoltenHideOutput<CR>", { desc = "close output window", silent = true })
  vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })
  vim.keymap.set("n", "<leader>mA", ":MoltenReevaluateAll<CR>", { desc = "Molten re-evaluate All", silent = true })
  vim.keymap.set("n", "<leader>m.", ":MoltenInterrupt<CR>", { desc = "Molten Interrupt", silent = true })
  -- { "<leader>mt", function()
  --   vim.g.molten_auto_open_output = not vim.g.molten_auto_open_output
  -- end, desc = "Molten toggle output", silent = true },
  vim.keymap.set("n", "]p", ":MoltenNext<CR>", { desc = "juPyter (molten/quarto) next cell", silent = true })
  vim.keymap.set(
    "n",
    "]P",
    ":MoltenNext<CR>zt",
    { desc = "juPyter (molten/quarto) next cell. Zoom Top", silent = true }
  )
  vim.keymap.set("n", "[p", ":MoltenPrev<CR>", { desc = "juPyter (molten/quarto) prev cell", silent = true })
  vim.keymap.set(
    "n",
    "[P",
    ":MoltenPrev<CR>zt",
    { desc = "juPyter (molten/quarto) prev cell. Zoom Top", silent = true }
  )
end

do -- quarto-dev/quarto-nvim
  require("quarto").setup({
    lspFeatures = {
      -- NOTE: put whatever languages you want here:
      languages = { "python" },
      chunks = "all",
      diagnostics = {
        enabled = true,
        triggers = { "BufWritePost" },
      },
      completion = {
        enabled = true,
      },
    },
    keymap = {
      -- NOTE: setup your own keymaps:
      hover = "H",
      definition = "gd",
      rename = "<leader>rn",
      references = "gr",
      format = "<leader>gf",
    },
    codeRunner = {
      enabled = true,
      default_method = "molten",
    },
  })
end

do -- jmbuhr/otter.nvim
  require("otter").setup({
    lsp = {
      -- `:h events` that cause the diagnostics to update. Set to:
      -- { "BufWritePost", "InsertLeave", "TextChanged" } for less performant
      -- but more instant diagnostic updates
      diagnostic_update_events = { "BufWritePost", "InsertLeave", "TextChanged" },
    },
  })
end

do -- Thiago4532/mdmath.nvim
end

do -- GCBallesteros/jupytext.nvim
  require("jupytext").setup({
    style = "markdown",
    output_extension = "md",
    force_ft = "markdown",
  })
  -- From jupytext repo
  -- require("jupytext").setup({
  --   style = "hydrogen",
  --   output_extension = "auto", -- Default extension. Don't change unless you know what you are doing
  --   force_ft = nil, -- Default filetype. Don't change unless you know what you are doing
  --   custom_language_formatting = {
  --     python = {
  --       extension = "qmd",
  --       style = "quarto",
  --       force_ft = "quarto", -- you can set whatever filetype you want here
  --     },
  --   },
  -- })
end

-- Disabled package/configuration retained for reference:
--[[
{ -- hydra
    "nvimtools/hydra.nvim",
    enabled = false,
    lazy = false,
  }
]]

do -- MeanderingProgrammer/render-markdown.nvim
  require("render-markdown").setup({
    heading = {
      sign = false,
    },
    code = {
      border = "thin",
      sign = false,
    },
    pipe_table = {
      enabled = true,
    },
    win_options = {
      conceallevel = {
        default = vim.o.conceallevel,
        rendered = 0,
      },
    },
  })
end
