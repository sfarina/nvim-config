local treesitter_filetypes = {
  "fish",
  "bash",
  "regex",
  "python",
  "c",
  "csv",
  "lua",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
  "xml",
  "make",
  "toml",
  "yaml",
  "ini",
}

-- CSV templates are still comma-separated tables while they are being edited.
-- Match the compound extension before the generic `.j2` detector sees it.
vim.filetype.add({
  pattern = {
    [".*%.csv%.j2"] = "csv",
  },
})

local function start_treesitter(buf, lang)
  local ok = pcall(vim.treesitter.start, buf, lang)
  if ok then
    return
  end

  -- Parser installation is asynchronous. Start Tree-sitter only after the
  -- install task has completed, and only if the buffer is still relevant.
  local ts_ok, treesitter = pcall(require, "nvim-treesitter")
  if not ts_ok then
    return
  end

  local installed, task = pcall(treesitter.install, { lang })
  if not installed then
    return
  end

  task:await(function(err)
    if err then
      return
    end

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= lang then
        return
      end
      pcall(vim.treesitter.start, buf, lang)
    end)
  end)
end

-- Enable native Tree-sitter highlighting for the current buffer.
vim.api.nvim_create_autocmd("FileType", {
  pattern = treesitter_filetypes,
  callback = function(args)
    start_treesitter(args.buf, args.match)
  end,
})

-- The initial file can complete FileType before init.lua has registered the
-- autocmd above. Retry for that buffer once startup has completed.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local lang = vim.bo[buf].filetype
    if vim.tbl_contains(treesitter_filetypes, lang) then
      start_treesitter(buf, lang)
    end
  end,
})

-- Reload files changed by another process when this buffer is unmodified.
-- With 'autoread', :checktime keeps the buffer in sync without prompting;
-- Neovim still warns when the buffer has local changes to protect them.
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("config-autoread", { clear = true }),
  pattern = "*",
  command = "silent! checktime",
})

-- Some preview integrations populate a real file buffer without changing its
-- contents.  Neovim can leave such a buffer marked modified; only clear that
-- flag after confirming that the buffer still matches the file on disk.
local function clear_false_modified(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].modified then
    return
  end

  local filename = vim.api.nvim_buf_get_name(buf)
  if filename == "" or vim.fn.filereadable(filename) ~= 1 then
    return
  end

  local disk_lines = vim.fn.readfile(filename)
  local buffer_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if vim.deep_equal(disk_lines, buffer_lines) then
    vim.bo[buf].modified = false
  end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = "*.py",
  callback = function(args)
    vim.schedule(function()
      clear_false_modified(args.buf)
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "txt", "tex" },
  callback = function(args)
    vim.opt_local.spell = true
    vim.opt_local.linebreak = true

    -- LSP hover uses a scratch Markdown buffer; it should not inherit prose
    -- spell checking from regular Markdown files.
    if args.match == "markdown" and vim.bo[args.buf].buftype == "nofile" then
      vim.opt_local.spell = false
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    require("quarto").activate()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit" },
  callback = function()
    vim.opt_local.linebreak = true
    vim.opt_local.wrap = true
  end,
})
