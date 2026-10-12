vim.filetype.add({
  extension = {
    sh = "bash",
  },
})

vim.filetype.add({
  filename = {
    Jenkinsfile = "groovy",
    jenkinsfile = "groovy",
  },
  pattern = {
    [".*%.jenkinsfile"] = "groovy",
    [".*%.Jenkinsfile"] = "groovy",
  },
})

vim.cmd("set clipboard=unnamedplus")
vim.o.winborder = "rounded"
vim.cmd("set ruler")
vim.cmd("set hlsearch")
vim.cmd("set nu")

vim.g.tex_no_math = 1
vim.g.python_highlight_all = 1
vim.opt.shortmess:append("I")

vim.wo.conceallevel = 0
vim.wo.concealcursor = "n"
vim.o.foldtext = ""
vim.opt.fillchars:append({ fold = " " })
-- vim.opt.foldcolumn = "1"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- vim.o.formatoptions = ""

vim.g.jupyter_mapkeys = 0

vim.g.c_syntax_for_h = 1

vim.cmd("syntax on")
vim.cmd("syntax sync minlines=10000")

-- sloppy aliases for shifted saves
vim.cmd([[cabbrev Wa wa]])
vim.cmd([[cabbrev Wq wq]])
vim.cmd([[cabbrev Qa qa]])
vim.cmd([[cabbrev W w]])
vim.cmd([[cabbrev Q q]])

function File_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

vim.cmd([[set completeopt+=menuone,noselect]])

function QuickfixGrep()
  local pat = vim.fn.input("g/re/p", "")
  vim.cmd("vimgrep /" .. pat .. "/ %")
  vim.cmd("copen")
end

vim.keymap.set("n", "<leader>/", QuickfixGrep, { desc = "Find: g/re/p in quickfix" })

-- unfold the line we're editing after leaving insert mode help deal with treesitter aggressive fold recalculations
vim.api.nvim_set_keymap("i", "<ESC>", "<ESC>zv", { noremap = true, silent = true })

vim.opt.foldlevelstart = 99
vim.opt.foldlevel = vim.o.foldlevelstart
-- Views should preserve editor layout, not a buffer's historical directory.
vim.opt.viewoptions = { "folds", "cursor" }

vim.cmd("highlight TreesitterContext guibg=NONE ctermbg=NONE ctermfg=6")
vim.cmd("highlight TreesitterContextBottom gui=underline guisp=#3485a8 guibg=NONE ctermbg=NONE")
vim.cmd("highlight TreesitterContextLineNumberBottom gui=underline guisp=#3485a8 guibg=NONE ctermbg=NONE")
