--------------------------------------------------------------------
-- Helper: API-based "zt" for a specific window
--------------------------------------------------------------------
local function zt_window(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  vim.api.nvim_win_call(win, function()
    local view = vim.fn.winsaveview()
    -- lnum is the current cursor line; make it the topline
    view.topline = view.lnum
    vim.fn.winrestview(view)
  end)
end

--------------------------------------------------------------------
-- Helper: request LSP definition at cursor and run a handler
--------------------------------------------------------------------
local function with_definition(handler)
  local source_buf = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_position_params()

  vim.lsp.buf_request(source_buf, "textDocument/definition", params, function(err, result, _, _)
    if err then
      vim.notify("LSP definition error: " .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify("No definition found", vim.log.levels.INFO)
      return
    end

    -- Some servers return a list of Locations, some LocationLinks
    local def = result[1]
    local uri = def.uri or def.targetUri
    local range = def.range or def.targetSelectionRange

    if not uri or not range then
      vim.notify("Malformed LSP definition result", vim.log.levels.WARN)
      return
    end

    local buf = vim.uri_to_bufnr(uri)
    if not vim.api.nvim_buf_is_loaded(buf) then
      vim.fn.bufload(buf)
    end

    handler({
      uri = uri,
      range = range,
      buf = buf,
    })
  end)
end

--------------------------------------------------------------------
-- grv: Open definition in a vertical split, stay in the split
--------------------------------------------------------------------
local function lsp_vsplit_definition()
  -- 1. Open a vertical split first: right-hand window becomes current
  vim.cmd("vsplit")
  vim.cmd("wincmd l") -- move to right split
  local right_win = vim.api.nvim_get_current_win()

  -- 2. Now request the definition *from this window's context*
  with_definition(function(def)
    if not vim.api.nvim_win_is_valid(right_win) then
      return
    end

    -- Show the definition buffer in the right split
    vim.api.nvim_win_set_buf(right_win, def.buf)
    vim.api.nvim_win_set_cursor(right_win, {
      def.range.start.line + 1,
      def.range.start.character,
    })

    -- 3. Align definition line to top in that right split
    zt_window(right_win)
  end)
end

--------------------------------------------------------------------
-- Internal: create a floating window for a given definition
-- focus = false  -> preview-only (cursor stays in main window)
-- focus = true   -> you can move cursor into the float
--------------------------------------------------------------------
local function open_definition_float(focus)
  local main_win = vim.api.nvim_get_current_win()

  with_definition(function(def)
    if not vim.api.nvim_win_is_valid(main_win) then
      return
    end

    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.6)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(def.buf, focus, {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = height,
      style = "minimal",
      border = "rounded",
    })

    -- Jump to definition location inside the float
    vim.api.nvim_win_set_cursor(win, {
      def.range.start.line + 1,
      def.range.start.character,
    })

    -- Align definition line to top (like `zt`)
    zt_window(win)

    if not focus then
      ----------------------------------------------------------------
      -- Non-focus peek: keep cursor in main window, close on move
      ----------------------------------------------------------------
      vim.api.nvim_set_current_win(main_win)

      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        callback = function()
          if
            vim.api.nvim_win_is_valid(main_win)
            and vim.api.nvim_get_current_win() == main_win
            and vim.api.nvim_win_is_valid(win)
          then
            vim.api.nvim_win_close(win, true)
          end
        end,
        once = true,
      })
    else
      ----------------------------------------------------------------
      -- Focusable peek: allow editing/scrolling in the float
      -- q closes it; leaving the window also closes it
      ----------------------------------------------------------------
      vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end, { buffer = def.buf, nowait = true })

      vim.api.nvim_create_autocmd("WinLeave", {
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end,
        once = true,
      })
    end
  end)
end

--------------------------------------------------------------------
-- Keymaps:
--   grv -> vsplit def (cursor stays in split)
--   grp -> peek def (non-focus float, closes on move)
--   grP -> peek def (focusable float)
--------------------------------------------------------------------
vim.keymap.set("n", "grv", lsp_vsplit_definition, {
  silent = true,
  desc = "LSP: definition in vertical split (cursor in split)",
})

vim.keymap.set("n", "grp", function()
  open_definition_float(false)
end, {
  silent = true,
  desc = "LSP: peek definition (preview float, cursor stays)",
})

vim.keymap.set("n", "grP", function()
  open_definition_float(true)
end, {
  silent = true,
  desc = "LSP: peek definition (focusable float)",
})
