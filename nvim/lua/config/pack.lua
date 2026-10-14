vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local function run_build(ev)
  if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
    return
  end
  local build = ev.data.spec.data and ev.data.spec.data.build
  if not build then
    return
  end
  vim.schedule(function()
    if not ev.data.active then
      vim.cmd.packadd(ev.data.spec.name)
    end
    vim.cmd(build)
  end)
end

vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("config-pack-build", { clear = true }),
  callback = run_build,
})

local packages = {
  { src = "https://github.com/3rd/image.nvim" },
  { src = "https://github.com/GCBallesteros/jupytext.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/Thiago4532/mdmath.nvim" },
  { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
  { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
  { src = "https://github.com/axkirillov/unified.nvim" },
  { src = "https://github.com/benlubas/molten-nvim", data = { build = "UpdateRemotePlugins" } },
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/folke/which-key.nvim" },
  { src = "https://github.com/hat0uma/csvview.nvim" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/jedrzejboczar/nvim-dap-cortex-debug" },
  { src = "https://github.com/jmbuhr/otter.nvim" },
  { src = "https://github.com/justinmk/vim-sneak" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mfussenegger/nvim-lint" },
  { src = "https://github.com/mfussenegger/nvim-dap" },
  { src = "https://github.com/mfussenegger/nvim-dap-python" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-mini/mini.ai" },
  { src = "https://github.com/nvim-mini/mini.completion", version = "stable" },
  { src = "https://github.com/nvim-mini/mini.cursorword" },
  { src = "https://github.com/nvim-mini/mini.files" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  { src = "https://github.com/nvim-mini/mini.notify" },
  { src = "https://github.com/nvim-mini/mini.snippets", version = "stable" },
  { src = "https://github.com/nvim-neotest/neotest" },
  { src = "https://github.com/nvim-neotest/neotest-python" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main", data = { build = "TSUpdate" } },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
  { src = "https://github.com/nvzone/minty" },
  { src = "https://github.com/nvzone/volt" },
  { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
  { src = "https://github.com/quarto-dev/quarto-nvim" },
  { src = "https://github.com/romgrk/barbar.nvim" },
  { src = "https://github.com/stevearc/aerial.nvim" },
  { src = "https://github.com/stevearc/conform.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/stevearc/overseer.nvim" },
  { src = "https://github.com/yochem/jq-playground.nvim" },
}

if vim.env.GITHUB_COPILOT_ENABLE == "1" then
  table.insert(packages, { src = "https://github.com/zbirenbaum/copilot.lua" })
end

-- Use :packupdate to reconcile these packages. Review the confirmation buffer,
-- accept it with :write or cancel it with :quit, then restart Neovim so updated
-- packages and generated artifacts load from a clean startup.
vim.pack.add(packages, { confirm = false, load = true })

-- Configure the colorscheme in editor before UI modules consume its highlights.
require("plugins.editor")
require("plugins.ui")
require("plugins.languages")
require("plugins.mini")
require("plugins.notebooks")
require("plugins.navigation")
require("config.quickfix").setup()
require("plugins.testing")
require("plugins.ai")
