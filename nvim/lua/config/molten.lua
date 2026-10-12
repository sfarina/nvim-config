-- Molten quarto notebook integration:
-- automatically import output chunks from a jupyter notebook
-- tries to find a kernel that matches the kernel in the jupyter notebook
-- falls back to a kernel that matches the name of the active venv (if any)
local imb = function(e) -- init molten buffer
  local buf = e.buf
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    return
  end
  if vim.b[buf].molten_import_scheduled or vim.b[buf].molten_imported then
    return
  end
  vim.b[buf].molten_import_scheduled = true

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_buf_get_name(buf) ~= file then
      return
    end

    local win = vim.fn.bufwinid(buf)
    if win == -1 then
      vim.b[buf].molten_import_scheduled = false
      return
    end

    local ok = pcall(function()
      vim.api.nvim_win_call(win, function()
        local kernels = vim.fn.MoltenAvailableKernels()
        local try_kernel_name = function()
          local metadata_file = io.open(file, "r")
          if not metadata_file then
            return nil
          end
          local metadata = vim.json.decode(metadata_file:read("a"))
          metadata_file:close()
          return metadata.metadata.kernelspec.name
        end
        local metadata_ok, kernel_name = pcall(try_kernel_name)
        if not metadata_ok or not vim.tbl_contains(kernels, kernel_name) then
          kernel_name = nil
          local venv = os.getenv("VIRTUAL_ENV")
          if venv ~= nil then
            kernel_name = string.match(venv, "/.+/(.+)")
          end
        end
        if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
          vim.cmd(("MoltenInit %s"):format(kernel_name))
          vim.cmd("QuartoActivate")
        end
        vim.cmd("MoltenImportOutput")
      end)
    end)

    if vim.api.nvim_buf_is_valid(buf) then
      vim.b[buf].molten_import_scheduled = false
      if ok then
        vim.b[buf].molten_imported = true
      end
    end
  end)
end

-- automatically import output chunks from a jupyter notebook
vim.api.nvim_create_autocmd("BufAdd", {
  pattern = { "*.ipynb" },
  callback = imb,
})

-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.ipynb" },
  callback = function(e)
    if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
      imb(e)
    end
  end,
})

-- automatically export output chunks to a jupyter notebook on write
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*.ipynb" },
  callback = function()
    if require("molten.status").initialized() == "Molten" then
      vim.cmd("MoltenExportOutput!")
    end
  end,
})

-- change the configuration when editing a python file
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.py",
  callback = function(e)
    if string.match(e.file, ".otter.") then
      return
    end
    if require("molten.status").initialized() == "Molten" then -- this is kinda a hack...
      vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
      vim.fn.MoltenUpdateOption("virt_text_output", false)
    else
      vim.g.molten_virt_lines_off_by_1 = false
      vim.g.molten_virt_text_output = false
    end
  end,
})

-- Undo those config changes when we go back to a markdown or quarto file
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.qmd", "*.md", "*.ipynb" },
  callback = function(e)
    if string.match(e.file, ".otter.") then
      return
    end
    if require("molten.status").initialized() == "Molten" then
      vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
      vim.fn.MoltenUpdateOption("virt_text_output", true)
    else
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_virt_text_output = true
    end
  end,
})

-- Provide a command to create a blank new Python notebook
-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
-- if you use another language than Python, you should change it in the template.
local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "python",
      "language": "python",
      "name": "python"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function new_notebook(filename)
  local path = filename .. ".ipynb"
  local file = io.open(path, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. path)
  else
    print("Error: Could not open new notebook file for writing.")
  end
end

vim.api.nvim_create_user_command("NewNotebook", function(opts)
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = "file",
})

local runner = require("quarto.runner")

vim.keymap.set("n", "<leader><cr>", function()
  runner.run_cell()
  vim.cmd("MoltenNext")
end, { desc = "run cell and jump to next", silent = true })
vim.keymap.set("n", "<leader>mm", runner.run_cell, { desc = "run cell", silent = true })
vim.keymap.set("n", "<leader>mg", runner.run_above, { desc = "run cell and above", silent = true })
vim.keymap.set("n", "<leader>mG", runner.run_below, { desc = "run cell and below", silent = true })
vim.keymap.set("n", "<leader>ml", runner.run_line, { desc = "run line", silent = true })

vim.api.nvim_create_user_command("NewNotebookCell", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "", "```python", "", "```" })
end, { nargs = 0 })
vim.keymap.set("n", "<leader>ma", "<cmd>NewNotebookCell<CR>", { desc = "New notebook cell" })

vim.api.nvim_create_user_command("NotebookPreamble", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, {
    "",
    "```python",
    "%load_ext autoreload",
    "%autoreload 2",
    "```",
    "",
    "```python",
    "from matplotlib import pyplot as plt",
    "import numpy as np",
    "import pandas as pd",
    "import seaborn as sns",
    "```",
  })
end, { nargs = 0 })
vim.keymap.set("n", "<leader>mi", "<cmd>NotebookPreamble<CR>", { desc = "NotebookPreamble" })
