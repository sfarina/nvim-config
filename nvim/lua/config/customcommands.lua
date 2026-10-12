function XmlTextOnly()
  vim.cmd("%!yq -pxml -o yml")
  vim.cmd("%!grep @text")
  vim.cmd('g/text: ""/d')
  vim.cmd("%s/^  *//")
  -- have to excape the backslash for vim substitution
  vim.cmd("%s/\\\\n/\r/g")
  -- vim.cmd([[%s/\V\\n/\r/g]])
end

function XmlFlat()
  vim.cmd("%!yq -pxml -o yml")
  vim.cmd("setlocal sw=2")
  vim.cmd("setlocal ts=2")
  vim.cmd("setlocal foldmethod=expr")
  vim.cmd("setlocal foldexpr=v:lua.vim.treesitter.foldexpr()")
end

vim.keymap.set("n", "<leader>cxt", XmlTextOnly, { desc = "Filter XML buffer to text only" })
vim.keymap.set("n", "<leader>cxx", XmlFlat, { desc = "Filter XML buffer to text only" })

-- python comment and docstring reflowing
local function with_builtin_gq(fn)
  local save_formatexpr = vim.bo.formatexpr
  local save_formatprg = vim.bo.formatprg
  vim.bo.formatexpr = ""
  vim.bo.formatprg = ""
  local ok, err = pcall(fn)
  vim.bo.formatexpr = save_formatexpr
  vim.bo.formatprg = save_formatprg
  if not ok then
    error(err)
  end
end

local function format_line_range(l1, l2, width)
  if l2 < l1 then
    return
  end
  local save_tw = vim.bo.textwidth
  vim.bo.textwidth = width

  with_builtin_gq(function()
    local save_pos = vim.fn.getpos(".")
    vim.fn.setpos(".", { 0, l1, 1, 0 })
    vim.cmd("normal! V")
    vim.fn.setpos(".", { 0, l2, 1, 0 })
    vim.cmd("normal! gq")
    vim.fn.setpos(".", save_pos)
  end)

  vim.bo.textwidth = save_tw
end

local function ts_node_at_cursor()
  local ok, ts = pcall(require, "vim.treesitter")
  if not ok then
    return nil
  end
  local node = ts.get_node({ ignore_injections = false })
  return node
end

local function find_ancestor(node, wanted)
  while node do
    if node:type() == wanted then
      return node
    end
    node = node:parent()
  end
  return nil
end

-- Expand to contiguous comment nodes directly above/below (no gaps).
local function comment_block_range(comment_node)
  local sr, _, er, _ = comment_node:range()
  local start_row, end_row = sr, er

  local function extend_dir(n, dir)
    local cur = n
    while true do
      local sib = (dir == "prev") and cur:prev_named_sibling() or cur:next_named_sibling()
      if not sib or sib:type() ~= "comment" then
        break
      end

      local csr, _, cer, _ = cur:range()
      local nsr, _, ner, _ = sib:range()

      -- Require adjacency: next comment starts at most 1 line away (no blank line between)
      if dir == "prev" then
        if csr - ner > 1 then
          break
        end
      else
        if nsr - cer > 1 then
          break
        end
      end

      cur = sib
    end
    return cur
  end

  local first = extend_dir(comment_node, "prev")
  local last = extend_dir(comment_node, "next")

  local fsr, _, _, _ = first:range()
  local _, _, ler, _ = last:range()
  start_row, end_row = fsr, ler

  -- Convert 0-based rows to 1-based line numbers for Vim
  return start_row + 1, end_row + 1
end

-- For a multi-line string node, format inside the quotes only.
-- This is a pragmatic approach: it formats full inner lines (not partial columns).
local function string_inner_range(str_node)
  local sr, sc, er, ec = str_node:range()
  if sr == er then
    return nil
  end -- single-line string: nothing safe to reflow

  -- Inner lines are sr+1 .. er-1 (exclude delimiter lines)
  local inner_start = sr + 2
  local inner_end = er

  if inner_start > inner_end then
    return nil
  end
  return inner_start, inner_end
end

local function py_reflow(width)
  if vim.bo.filetype ~= "python" then
    return
  end
  width = width or 100

  local node = ts_node_at_cursor()
  if not node then
    return
  end

  local comment = find_ancestor(node, "comment")
  if comment then
    local l1, l2 = comment_block_range(comment)
    format_line_range(l1, l2, width)
    return
  end

  local str = find_ancestor(node, "string") or find_ancestor(node, "string_content") -- depending on cursor position
  if str and str:type() ~= "string" then
    str = find_ancestor(str, "string")
  end

  if str then
    local l1, l2 = string_inner_range(str)
    if l1 and l2 then
      format_line_range(l1, l2, width)
    end
    return
  end
end

vim.api.nvim_create_user_command("PyReflow", function(opts)
  py_reflow(tonumber(opts.args) or 100)
end, { nargs = "?" })

vim.keymap.set("n", "<leader>q", function()
  py_reflow(100)
end, { desc = "Reflow Python comment block / docstring to 100" })
