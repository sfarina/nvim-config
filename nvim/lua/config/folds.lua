local fold_views = vim.api.nvim_create_augroup("fold-views", { clear = true })
local function should_persist_view(buf)
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

local function save_view(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end

  pcall(function()
    vim.api.nvim_win_call(win, function()
      vim.cmd("silent! mkview!")
    end)
  end)
end

local function load_view(win)
  local line, col = unpack(vim.api.nvim_win_get_cursor(win))
  if line ~= 1 or col ~= 0 then
    return
  end
  pcall(function()
    vim.api.nvim_win_call(win, function()
      vim.cmd("silent! loadview")
    end)
  end)
end

local function configure_folds(buf, win)
  vim.api.nvim_set_option_value("foldmethod", "expr", { scope = "local", win = win })
  vim.api.nvim_set_option_value("foldexpr", "v:lua.vim.treesitter.foldexpr()", { scope = "local", win = win })
  if vim.wo[win].foldlevel == 0 then
    vim.api.nvim_set_option_value("foldlevel", vim.o.foldlevelstart, { scope = "local", win = win })
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = fold_views,
  callback = function(args)
    local win = vim.api.nvim_get_current_win()

    -- BufWinEnter can run before the filetype and Tree-sitter parser are ready.
    -- Recheck here so filetype buffers do not remain stuck with manual folds.
    vim.schedule(function()
      if
        not vim.api.nvim_buf_is_valid(args.buf)
        or not vim.api.nvim_win_is_valid(win)
        or vim.api.nvim_win_get_buf(win) ~= args.buf
      then
        return
      end

      configure_folds(args.buf, win)
    end)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = fold_views,
  callback = function()
    vim.schedule(function()
      local win = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_is_valid(buf) and should_persist_view(buf) then
        configure_folds(buf, win)
        load_view(win)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost" }, {
  group = fold_views,
  callback = function(args)
    if not should_persist_view(args.buf) then
      return
    end

    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == args.buf then
        save_view(win)
      end
    end
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = fold_views,
  callback = function(args)
    if not should_persist_view(args.buf) then
      return
    end

    local win = vim.api.nvim_get_current_win()

    -- Defer fold setup until the window is ready, then restore the saved view.
    vim.schedule(function()
      if
        not vim.api.nvim_buf_is_valid(args.buf)
        or not vim.api.nvim_win_is_valid(win)
        or vim.api.nvim_win_get_buf(win) ~= args.buf
      then
        return
      end

      configure_folds(args.buf, win)
      load_view(win)
    end)
  end,
})
