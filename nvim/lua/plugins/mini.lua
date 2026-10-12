-- Plugin packages are installed centrally by config.pack.

-- Disabled package/configuration retained for reference:
--[[
{ -- mini.map
    "echasnovski/mini.map",
    lazy = false,
    enabled = false,
    config = function()
      local map = require("mini.map")
      local SymbolKind = vim.lsp.protocol.SymbolKind

      local function symbols_integration()
        return function()
          local out = {}
          local params = { textDocument = vim.lsp.util.make_text_document_params() }
          local responses = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 200)

          if not responses then
            return out
          end

          local seen = {}

          local function add_symbols(symbols)
            for _, sym in ipairs(symbols or {}) do
              local range = sym.selectionRange or sym.range
              if range and range.start then
                local line = range.start.line + 1

                local hl = nil
                if sym.kind == SymbolKind.Class then
                  hl = "MiniMapSymbolClass"
                elseif sym.kind == SymbolKind.Method then
                  hl = "MiniMapSymbolMethod"
                elseif sym.kind == SymbolKind.Function then
                  hl = "MiniMapSymbolFunction"
                elseif sym.kind == SymbolKind.Interface then
                  hl = "MiniMapSymbolInterface"
                end

                if hl and not seen[line .. ":" .. hl] then
                  table.insert(out, { line = line, hl_group = hl })
                  seen[line .. ":" .. hl] = true
                end
              end

              if sym.children then
                add_symbols(sym.children)
              end
            end
          end

          for _, resp in pairs(responses) do
            if resp.result then
              add_symbols(resp.result)
            end
          end

          return out
        end
      end

      vim.api.nvim_set_hl(0, "MiniMapSymbolClass", { link = "Type" })
      vim.api.nvim_set_hl(0, "MiniMapSymbolMethod", { link = "Function" })
      vim.api.nvim_set_hl(0, "MiniMapSymbolFunction", { link = "Identifier" })
      vim.api.nvim_set_hl(0, "MiniMapSymbolInterface", { link = "Special" })

      map.setup({
        integrations = {
          symbols_integration(),
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic(),
        },
        window = {
          width = 12,
          show_integration_count = false,
        },
      })

      vim.api.nvim_create_autocmd({ "LspAttach", "BufEnter", "BufWritePost" }, {
        callback = function()
          pcall(MiniMap.refresh, "integrations")
        end,
      })
    end,
    keys = {
      {
        "<leader>nm",
        function()
          require("mini.map").toggle()
        end,
        desc = "Toggle mini.map",
      },
      {
        "<leader>nf",
        function()
          require("mini.map").toggle_focus()
        end,
        desc = "Toggle mini.map",
      },
    },
  }
]]
