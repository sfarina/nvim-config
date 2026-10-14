-- A small native preview for the item under the cursor in quickfix.
-- The preview is deliberately non-focusable: quickfix remains the navigation UI.

local M = {}

local preview_win
local preview_buf
local quickfix_win
local source_win
local preview_generation = 0
local restore_source
local pending_gitsigns_previews = {}
local gitsigns_update_listener = false
local namespace = vim.api.nvim_create_namespace("quickfix-preview")

local function close_preview()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    vim.api.nvim_win_close(preview_win, true)
  end
  preview_win = nil
  preview_buf = nil
end

local function item_filename(item)
  if item.bufnr and item.bufnr > 0 then
    local name = vim.api.nvim_buf_get_name(item.bufnr)
    if name ~= "" then
      return name
    end
  end
  return item.filename or ""
end

local function close_gitsigns_preview()
  local ok, popup = pcall(require, "gitsigns.popup")
  if ok then
    popup.close("hunk")
  end
end

local function restore_source_buffer()
  if restore_source then
    local restore = restore_source
    restore_source = nil
    restore()
  end
end

local function close_all_previews()
  preview_generation = preview_generation + 1
  close_preview()
  close_gitsigns_preview()
  restore_source_buffer()
end

local function quickfix_data()
  return vim.fn.getqflist({ items = 1, title = 1 })
end

local function is_gitsigns_list(qf)
  return qf.title == "Hunks"
end

local function current_quickfix_item(qf_win)
  if not qf_win or not vim.api.nvim_win_is_valid(qf_win) then
    return
  end
  local qf = quickfix_data()
  local row = vim.api.nvim_win_get_cursor(qf_win)[1]
  return qf, qf.items[row]
end

local function update_gitsigns_preview(qf, item, generation)
  for bufnr in pairs(pending_gitsigns_previews) do
    pending_gitsigns_previews[bufnr] = nil
  end
  restore_source_buffer()
  close_preview()
  close_gitsigns_preview()
  if #qf.items == 1 or not item or not source_win or not vim.api.nvim_win_is_valid(source_win) then
    return
  end

  local filename = item_filename(item)
  if filename == "" or vim.fn.filereadable(filename) == 0 then
    return
  end

  local bufnr = item.bufnr
  if not bufnr or bufnr == 0 or not vim.api.nvim_buf_is_valid(bufnr) then
    bufnr = vim.fn.bufadd(filename)
  end
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end
  if vim.bo[bufnr].filetype == "" then
    local filetype = vim.filetype.match({ filename = filename })
    if filetype then
      vim.bo[bufnr].filetype = filetype
    end
  end

  local manager = require("gitsigns.manager")
  if not gitsigns_update_listener then
    manager.on_update(function(ctx)
      local callback = pending_gitsigns_previews[ctx.bufnr]
      if callback then
        pending_gitsigns_previews[ctx.bufnr] = nil
        vim.schedule(callback)
      end
    end)
    gitsigns_update_listener = true
  end

  local original_buf = vim.api.nvim_win_get_buf(source_win)
  local original_cursor = vim.api.nvim_win_get_cursor(source_win)
  local function restore_original_source()
    if not vim.api.nvim_win_is_valid(source_win) then
      return
    end
    vim.api.nvim_win_set_buf(source_win, original_buf)
    if vim.api.nvim_buf_is_valid(original_buf) then
      local original_line_count = vim.api.nvim_buf_line_count(original_buf)
      vim.api.nvim_win_set_cursor(source_win, {
        math.max(1, math.min(original_cursor[1], original_line_count)),
        original_cursor[2],
      })
    end
  end
  local function restore_this_source()
    if restore_source ~= restore_original_source then
      return
    end
    restore_source = nil
    restore_original_source()
  end
  restore_source = restore_original_source

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local ok = pcall(function()
    vim.api.nvim_win_set_buf(source_win, bufnr)
    vim.api.nvim_win_set_cursor(source_win, { math.max(1, math.min(item.lnum or 1, line_count)), 0 })
  end)
  if not ok then
    restore_source_buffer()
    return
  end

  local function show_preview()
    if generation ~= preview_generation or not quickfix_win or not vim.api.nvim_win_is_valid(quickfix_win) then
      restore_this_source()
      return
    end

    local latest_qf, latest_item = current_quickfix_item(quickfix_win)
    if
      not latest_qf
      or not is_gitsigns_list(latest_qf)
      or not latest_item
      or item_filename(latest_item) ~= filename
      or latest_item.lnum ~= item.lnum
    then
      restore_this_source()
      return
    end

    local preview_ok = pcall(vim.api.nvim_win_call, source_win, function()
      require("gitsigns").preview_hunk()
    end)
    restore_this_source()
    if not preview_ok then
      close_gitsigns_preview()
    end
  end

  local hunks = require("gitsigns").get_hunks(bufnr)
  if hunks and #hunks > 0 then
    show_preview()
    return
  end

  pending_gitsigns_previews[bufnr] = show_preview
  require("gitsigns").attach({ bufnr = bufnr, trigger = "quickfix-preview", force = true }, function(err)
    if err and pending_gitsigns_previews[bufnr] == show_preview then
      pending_gitsigns_previews[bufnr] = nil
      restore_this_source()
    end
  end)
end

local function update_source_preview(qf, item)
  close_gitsigns_preview()
  if #qf.items == 1 or not item then
    close_preview()
    return
  end

  if not quickfix_win or not vim.api.nvim_win_is_valid(quickfix_win) then
    close_preview()
    return
  end

  local filename = item_filename(item)
  if filename == "" or vim.fn.filereadable(filename) == 0 then
    close_preview()
    return
  end

  local lines = vim.fn.readfile(filename)
  local line = math.max(item.lnum or 1, 1)
  local context = 3
  local first = math.max(line - context, 1)
  local last = math.min(line + context, #lines)
  local preview_lines = {}
  for index = first, last do
    preview_lines[#preview_lines + 1] = lines[index]
  end

  if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
    preview_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[preview_buf].buftype = "nofile"
    vim.bo[preview_buf].bufhidden = "wipe"
    vim.bo[preview_buf].swapfile = false
  end

  vim.bo[preview_buf].modifiable = true
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, preview_lines)
  vim.api.nvim_buf_clear_namespace(preview_buf, namespace, 0, -1)
  vim.api.nvim_buf_set_extmark(preview_buf, namespace, line - first, 0, {
    line_hl_group = "CursorLine",
  })
  vim.bo[preview_buf].filetype = vim.filetype.match({ filename = filename }) or ""

  local width = math.min(100, math.max(40, vim.o.columns - 4))
  local height = math.min(#preview_lines, math.max(1, vim.o.lines - 8))
  local config = {
    relative = "editor",
    row = 1,
    col = math.max(vim.o.columns - width - 2, 0),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    focusable = false,
    noautocmd = true,
    title = string.format(" %s:%d ", vim.fn.fnamemodify(filename, ":~."), line),
    title_pos = "center",
  }

  if not preview_win or not vim.api.nvim_win_is_valid(preview_win) then
    preview_win = vim.api.nvim_open_win(preview_buf, false, config)
  else
    vim.api.nvim_win_set_config(preview_win, config)
    vim.api.nvim_win_set_buf(preview_win, preview_buf)
  end
end

local function update_preview()
  if not quickfix_win or not vim.api.nvim_win_is_valid(quickfix_win) then
    close_all_previews()
    return
  end

  local qf, item = current_quickfix_item(quickfix_win)
  if not qf then
    close_all_previews()
    return
  end

  if is_gitsigns_list(qf) then
    preview_generation = preview_generation + 1
    update_gitsigns_preview(qf, item, preview_generation)
  else
    preview_generation = preview_generation + 1
    update_source_preview(qf, item)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("quickfix-preview", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "qf",
    callback = function(args)
      quickfix_win = vim.api.nvim_get_current_win()
      source_win = vim.fn.win_getid(vim.fn.winnr("#"))
      if not source_win or source_win == quickfix_win or not vim.api.nvim_win_is_valid(source_win) then
        source_win = nil
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if win ~= quickfix_win and vim.api.nvim_win_get_config(win).relative == "" then
            source_win = win
            break
          end
        end
      end
      vim.keymap.set("n", "q", "<cmd>cclose<CR>", {
        buffer = args.buf,
        desc = "Close quickfix list",
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = args.buf,
        callback = function()
          if vim.api.nvim_get_current_win() == quickfix_win then
            vim.schedule(update_preview)
          end
        end,
      })
      update_preview()
    end,
  })

  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    pattern = "*",
    callback = function()
      if quickfix_win == vim.api.nvim_get_current_win() then
        close_all_previews()
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      if tonumber(args.match) == quickfix_win then
        quickfix_win = nil
        source_win = nil
        close_all_previews()
      end
    end,
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    pattern = "*",
    callback = function()
      if vim.bo.filetype ~= "qf" then
        return
      end

      local normal_windows = 0
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_config(win).relative == "" then
          normal_windows = normal_windows + 1
        end
      end

      if normal_windows == 1 then
        vim.cmd("quit")
      end
    end,
  })
end

return M
