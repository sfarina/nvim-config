vim.keymap.set("n", "<C-h>", "<C-w><C-h>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-l>", "<C-w><C-l>")

vim.keymap.set("n", "<C-Tab>", "gt")
vim.keymap.set("n", "<C-S-Tab>", "gT")

vim.keymap.set("n", "zV", function()
  if vim.wo.conceallevel == 0 then
    vim.wo.conceallevel = 2
  else
    vim.wo.conceallevel = 0
  end
end, { desc = "Toggle conceals" })

vim.keymap.set("n", "U", ":redo<CR>")
vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>")

vim.keymap.set("n", "<leader>]", "<cmd>lua = vim.diagnostic.goto_next()<CR>zz")
vim.keymap.set("n", "<leader>[", "<cmd>lua = vim.diagnostic.goto_prev()<CR>zz")

vim.keymap.set("n", "<leader>vl", "<cmd>Lazy<CR>")
vim.keymap.set("n", "<leader>vm", "<cmd>Mason<CR>")

vim.keymap.set("n", "<C-CR>", function()
  vim.cmd("JupyterSendCell")
end)
vim.keymap.set("n", "<leader><CR>", function()
  vim.cmd("JupyterSendCell")
end)
vim.keymap.set("n", "<esc>", function() end)

vim.keymap.set("n", "tt", "<cmd>tabnew<CR>")
vim.keymap.set("n", "<C-w>`", "<cmd>resize 6<CR>", { desc = "resize window to 6 big" })

vim.keymap.set("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>")
-- vim.keymap.set("n", "K", function() vim.lsp.buf.hover({close_events={"InsertLeave"}})end)
vim.keymap.set({ "i", "n" }, "<C-s>", function()
  vim.lsp.buf.signature_help({ close_events = { "InsertLeave" } })
end)
vim.keymap.set("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "LSP toggle inlay Hints" })
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format()
end, { desc = "LSP Format" })
vim.keymap.set("n", "<leader>li", function()
  vim.lsp.buf.incoming_calls()
end, { desc = "LSP Incoming calls" })

-- leave terminal float with normal movement shortcuts.
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")
