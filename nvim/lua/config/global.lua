vim.cmd("set clipboard=unnamedplus")
vim.cmd("set notitle")
vim.cmd("set noicon")
vim.cmd("set tabstop=4")
vim.cmd("set expandtab")
vim.cmd("set ruler")
vim.cmd("set hlsearch")
vim.cmd("set nu")

vim.g.tex_no_math = 1
vim.g.python_highlight_all = 1

vim.wo.conceallevel = 0
vim.wo.concealcursor = "n"

vim.g.jupyter_mapkeys = 0

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "bash", "fish", "sh", "c", "markdown", "xml", "lua", "yaml", "vim", "groovy", "json" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})


vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "txt", "tex" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.linebreak = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sh" },
  callback = function()
    vim.opt.filetype = "bash"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "javascript" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

vim.cmd("syntax on")
vim.cmd("syntax sync minlines=10000")

vim.diagnostic.config({ virtual_text = true })

function File_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end
vim.opt.foldlevel = 99

vim.cmd([[set completeopt+=menuone,noselect,popup]])
-- vim.lsp.inlay_hint.enable(true)

vim.cmd.source("~/.config/nvim/vimrc.vim")

if vim.g.neovide then
  vim.cmd.source("~/.config/nvim/neovide.vim")
  vim.cmd("hi Normal ctermbg=NONE guibg=#002030")
end

vim.cmd("set signcolumn=yes")

function TroubleGrep()
  vim.cmd("Trouble close")
  local pat = vim.fn.input("g/re/p", "")
  vim.cmd("vimgrep /" .. pat .. "/ %")
  vim.cmd("Trouble quickfix open focus=true")
end

vim.keymap.set("n", "<leader>/", TroubleGrep, { desc = "Find: g/re/p but open in trouble" })

-- function DoMake()
--   local tgt = vim.fn.input("Make", "")
--   vim.cmd("vimgrep /" .. tgt .. "/ %")
-- end

-- unfold the line we're editing after leaving insert mode help deal with treesitter aggressive fold recalculations
vim.api.nvim_set_keymap("i", "<ESC>", "<ESC>zv", { noremap = true, silent = true })
vim.opt.foldlevel = 99
