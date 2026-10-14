-- To use `ALT+{h,j,k,l}` to navigate windows from any mode: >vim
vim.keymap.set("n", "<A-h>", "<C-w><C-h>")
vim.keymap.set("n", "<A-j>", "<C-w><C-j>")
vim.keymap.set("n", "<A-k>", "<C-w><C-k>")
vim.keymap.set("n", "<A-l>", "<C-w><C-l>")
vim.keymap.set("i", "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("i", "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("i", "<A-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("i", "<A-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("t", "<A-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<A-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<A-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<A-l>", "<C-\\><C-N><C-w>l")

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
-- vim.keymap.set("n", "<leader>cd", ":cd %:p:h<CR>")

-- package management
vim.keymap.set("n", "<leader>vm", function()
  vim.cmd("Mason")
end, { desc = "Mason package manager" })

vim.keymap.set("n", "<leader>vp", function()
  vim.pack.update()
end, { desc = "Manage and update packages" })

-- window shortcuts
vim.keymap.set("n", "<leader>ws", "<cmd>split<CR>", { desc = "Window Split (hamburger)" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Window Vertical split (hotdog)" })
vim.keymap.set("n", "<leader>wo", "<C-w><C-o>", { desc = "Window Only this one" })
vim.keymap.set("n", "<leader>w`", "<cmd>resize 6<CR>", { desc = "Set window to height to console (6 big)" })
vim.keymap.set("n", "<leader>wh", "<C-w>_", { desc = "Maximize window height" })
vim.keymap.set("n", "<leader>ww", "<C-w>|", { desc = "Maximize window width" })

vim.keymap.set("n", "<leader>zx", "<cmd>set fdm=expr<CR>", { desc = "set foldmethod to expr" })
vim.keymap.set("n", "<leader>zz", "<cmd>loadview<CR>", { desc = "set foldmethod to expr" })

vim.keymap.set("n", "<esc>", function() end)

vim.keymap.set("n", "tt", "<cmd>tabnew<CR>")
vim.keymap.set("n", "<C-w>`", "<cmd>resize 6<CR>", { desc = "resize window to mini (6 big)" })

vim.keymap.set("n", "<A-[>", "<cmd>BufferPrevious<CR>", { desc = "Goto Previous buffer" })
vim.keymap.set("n", "<A-]>", "<cmd>BufferNext<CR>", { desc = "Goto Next buffer" })
vim.keymap.set("n", "gn", "<cmd>BufferNext<CR>", { desc = "Goto Next buffer" })
vim.keymap.set("n", "gp", "<cmd>BufferPrevious<CR>", { desc = "Goto Previous buffer" })
vim.keymap.set("n", "gd", "<cmd>BufferClose<CR>", { desc = "Go ahead and Delete this buffer" })
vim.keymap.set("n", "go", "<cmd>BufferCloseAllButCurrentOrPinned<CR>", { desc = "close Other buffers" })
vim.keymap.set("n", "gb", "<cmd>BufferLast<CR>", { desc = "Go Back to last buffer" })
vim.keymap.set("n", "<C-p>", "<cmd>BufferPick<CR>", { desc = "Pick a buffer" })
-- vim.keymap.set("n", "<C-P>", "<cmd>BufferPin<CR>", { desc = "Pin a buffer" })
--
-- List-producing LSP functions use the quickfix list by default, which keeps
-- navigation on Vim's built-ins.
local function diagnostics(all_buffers)
  if all_buffers then
    vim.diagnostic.setqflist({ open = true, title = "Diagnostics" })
    return
  end

  local items = vim.diagnostic.toqflist(vim.diagnostic.get(vim.api.nvim_get_current_buf()))
  vim.fn.setqflist(items, "r", { title = "Buffer diagnostics" })
  vim.cmd("copen")
end

vim.keymap.set("n", "grd", "<cmd>lua vim.lsp.buf.definition()<CR>")
vim.keymap.set("n", "grD", "<cmd>lua vim.lsp.buf.declaration()<CR>")

vim.keymap.set("n", "<leader>xx", function()
  diagnostics(true)
end, { desc = "Diagnostics (quickfix)" })
vim.keymap.set("n", "<leader>xX", function()
  diagnostics(false)
end, { desc = "Buffer diagnostics (quickfix)" })
-- vim.keymap.set("n", "<leader>ls", vim.lsp.buf.document_symbol, { desc = "LSP symbols (quickfix)" })
vim.keymap.set("n", "<leader>ls", "<cmd>AerialToggle!<CR>", { desc = "Aerial Symbol map" })
-- vim.keymap.set("n", "<leader>la", vim.lsp.buf.workspace_symbol, { desc = "LSP workspace symbols (quickfix)" })
vim.keymap.set("n", "<leader>lr", "<CMD>FzfLua lsp_references<CR>", { desc = "LSP references (fzf)" })
vim.keymap.set("n", "<leader>li", "<CMD>FzfLua lsp_incoming_calls<CD>", { desc = "LSP incoming calls (fzf)" })
vim.keymap.set("n", "<leader>li", "<CMD>FzfLua lsp_outgoing_calls<CD>", { desc = "LSP outgoing calls (fzf)" })
vim.keymap.set("n", "<leader>lu", "<CMD>FzfLua lsp_implementations<CR>", { desc = "LSP implementations (fzf)" })
vim.keymap.set("n", "<leader>lT", "<CMD>FzfLua lsp_type_sub<CR>", { desc = "LSP show subtypes (fzf)" })
vim.keymap.set("n", "<leader>xL", "<cmd>lopen<CR>", { desc = "Open location list" })
vim.keymap.set("n", "<leader>xQ", "<cmd>copen<CR>", { desc = "Open quickfix list" })

-- dap

vim.keymap.set("n", "<leader>db", "<cmd>OverseerToggle<CR>", { desc = "Debug: Build Task Output" })
vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug: Toggle UI Sidebar" })

vim.keymap.set({ "n", "v" }, "<leader>de", function()
  require("dapui").eval()
end, { desc = "Debug: Evaluate Expression" })

vim.keymap.set("n", "<leader>dx", function()
  require("config.dap").run_tests()
end, { desc = "Debug: Run Project Tests" })
vim.keymap.set("n", "<leader>dn", function()
  vim.cmd("DapNew")
end, { desc = "Debug: New" })
vim.keymap.set("n", "<leader>d.", function()
  require("dap").run_to_cursor()
end, { desc = "Debug: run to cursor" })
vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<leader>dh", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<leader>dl", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<leader>dj", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>dk", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Conditional Breakpoint" })

vim.keymap.set("n", "<leader>dt", function()
  require("dap").terminate()
end, { desc = "Debug: Terminate" })
vim.keymap.set("n", "<leader>dR", function()
  require("dap").run_last()
end, { desc = "Debug: Run Last" })
vim.keymap.set("n", "<leader>dr", function()
  require("dap").repl.toggle()
end, { desc = "Debug: REPL / Output" })
vim.keymap.set({ "n", "v" }, "<leader>dv", function()
  require("dap.ui.widgets").hover()
end, { desc = "Debug: Inspect Value" })
vim.keymap.set("n", "<leader>ds", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.scopes)
end, { desc = "Debug: Variables / Scopes" })
vim.keymap.set("n", "<leader>df", function()
  local widgets = require("dap.ui.widgets")
  widgets.centered_float(widgets.frames)
end, { desc = "Debug: Stack Frames" })
