local completion_capabilities = MiniCompletion.get_lsp_capabilities({
  -- Completion should insert the label only: no snippet placeholders or
  -- automatic imports/additional edits.
  resolve_additional_text_edits = false,
})
completion_capabilities.textDocument = completion_capabilities.textDocument or {}
completion_capabilities.textDocument.completion = completion_capabilities.textDocument.completion or {}
completion_capabilities.textDocument.completion.completionItem = completion_capabilities.textDocument.completion.completionItem
  or {}
completion_capabilities.textDocument.completion.completionItem.snippetSupport = false

local capabilities = vim.tbl_deep_extend("force", completion_capabilities, {
  textDocument = {
    publishDiagnostics = {
      codeDescriptionSupport = true,
    },
    -- enable document links
    documentLink = {
      dynamicRegistration = false,
      tooltipSupport = true,
    },
  },
})

vim.lsp.config("*", {
  capabilities = capabilities,
})

local function toggle_signature_help()
  local source_buf = vim.api.nvim_get_current_buf()

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local ok, owner_buf = pcall(vim.api.nvim_win_get_var, win, "textDocument/signatureHelp")
      if ok and owner_buf == source_buf then
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  end

  vim.lsp.buf.signature_help({ close_events = { "InsertLeave" } })
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("config-lsp-signature-toggle", { clear = true }),
  callback = function(args)
    vim.keymap.set({ "i", "n" }, "<C-s>", toggle_signature_help, {
      buffer = args.buf,
      desc = "LSP: toggle signature help",
    })
  end,
})

local function brew_tool(formula, tool)
  local brew = vim.fn.exepath("brew")
  if brew == "" then
    return tool
  end

  local prefix = vim.fn.trim(vim.fn.system({ brew, "--prefix", formula }))
  if vim.v.shell_error ~= 0 or prefix == "" then
    return tool
  end

  return prefix .. "/bin/" .. tool
end

vim.lsp.config("clangd", {
  cmd = { brew_tool("llvm", "clangd"), "--clang-tidy" },
})

vim.lsp.config("ruff", {
  capabilities = {
    general = {
      -- positionEncodings = { "utf-8", "utf-16", "utf-32" }  <--- this is the default
      positionEncodings = { "utf-16" },
    },
  },
})

vim.lsp.config("zls", {
  cmd = { "zls", "--config-path", "~/.config/zig/zls.json" },
})

vim.lsp.config("ctags_lsp", {
  cmd = { "ctags-lsp" },
  filetypes = { "toml" },
})
vim.lsp.enable("ctags_lsp")

vim.lsp.config("ansiblels", {
  cmd = { "ansible-language-server", "--stdio" },
  filetypes = { "yaml", "yml" },
})

local function enable_ansible_for_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.tbl_contains({ "yaml", "yml" }, vim.bo[bufnr].filetype) then
    vim.notify("Ansible support is only available for YAML buffers", vim.log.levels.WARN)
    return
  end

  vim.b[bufnr].ansible_enabled = true
  vim.lsp.start(vim.lsp.config.ansiblels, { bufnr = bufnr })
end

vim.api.nvim_create_user_command("Ansible", enable_ansible_for_current_buffer, {
  desc = "Enable Ansible LSP for the current YAML buffer",
})

-- User commands must start with an uppercase letter, but accept the natural
-- lowercase spelling too.
vim.cmd([[cnoreabbrev <expr> ansible getcmdtype() ==# ':' && getcmdline() ==# 'ansible' ? 'Ansible' : 'ansible']])

vim.diagnostic.config({
  virtual_text = {
    severity = {
      min = vim.diagnostic.severity.INFO,
    },
  },
  signs = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },

  underline = {
    severity = {
      min = vim.diagnostic.severity.ERROR,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  float = {
    severity = {
      min = vim.diagnostic.severity.WARN,
    },
  },
  -- Sort by severity
  severity_sort = true,
})

-- LSP keymaps

vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<leader>ld", function()
  vim.diagnostic.open_float()
end, { desc = "Show diagnostic details" })

vim.keymap.set("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "LSP toggle inlay Hints" })
vim.keymap.set("n", "<leader>lf", function()
  vim.lsp.buf.format()
end, { desc = "LSP Format" })

vim.keymap.set("n", "<leader>lq", function()
  local bufnr = vim.api.nvim_get_current_buf()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    vim.lsp.buf_detach_client(bufnr, client.id)
  end
end, { desc = "LSP detach all clients from buffer" })

vim.keymap.set("n", "<leader>lt", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled(), { bufnr = 0 })
end, { desc = "Toggle diagnostics" })
