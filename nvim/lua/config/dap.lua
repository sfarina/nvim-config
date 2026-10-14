local dap = require("dap")

-- The adapter uses Neovim's tooling venv; debuggees use their project venv.
require("dap-python").setup(vim.fn.expand(vim.g.python3_host_prog or "~/.nvim_venv/bin/python"), {
  console = "internalConsole",
})

-- Honor shared tasks.json preLaunchTask/postDebugTask definitions.
require("overseer").setup()

-- Open the inspection sidebar explicitly; the existing REPL owns test output.
require("dapui").setup({
  layouts = {
    {
      elements = { "scopes", "stacks", "watches", "breakpoints" },
      size = 40,
      position = "left",
    },
  },
})

local pane_elements = {
  dapui_scopes = "scopes",
  dapui_stacks = "stacks",
  dapui_watches = "watches",
  dapui_breakpoints = "breakpoints",
}
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config-dap-pane-floats", { clear = true }),
  pattern = vim.tbl_keys(pane_elements),
  callback = function(ev)
    local element = pane_elements[ev.match]
    vim.keymap.set("n", "v", function()
      if element == "scopes" or element == "stacks" then
        local widgets = require("dap.ui.widgets")
        widgets.centered_float(element == "scopes" and widgets.scopes or widgets.frames)
      else
        require("dapui").float_element(element, { enter = true })
      end
    end, { buffer = ev.buf, desc = "Debug: Float " .. element })
  end,
})

-- Cortex-Debug bridges DAP to ARM GDB's MI interface and OpenOCD.
require("dap-cortex-debug").setup({ dapui_rtt = false })

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("config-dap-repl", { clear = true }),
  pattern = "dap-repl",
  callback = function(ev)
    -- Use the debugger's omnifunc rather than LSP completion in this buffer.
    vim.b[ev.buf].minicompletion_disable = true
    vim.keymap.set("i", "<Tab>", function()
      local keys = vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-o>"
      return vim.api.nvim_replace_termcodes(keys, true, false, true)
    end, { buffer = ev.buf, expr = true, desc = "Complete debugger symbols" })
  end,
})

local float_group = vim.api.nvim_create_augroup("config-dap-floats", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = float_group,
  pattern = "dap-float",
  callback = function(ev)
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true, desc = "Close debug float" })
    local win = vim.api.nvim_get_current_win()
    -- DAP sets the filetype twice while opening a widget.
    vim.api.nvim_clear_autocmds({ group = float_group, event = "WinLeave", buffer = ev.buf })
    vim.api.nvim_create_autocmd("WinLeave", {
      group = float_group,
      buffer = ev.buf,
      callback = function()
        -- Close after Neovim finishes switching windows.
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(win) and vim.api.nvim_get_current_win() ~= win then
            vim.api.nvim_win_close(win, true)
          end
        end)
      end,
    })
  end,
})

-- Prefer the LLVM adapter on PATH; Apple's toolchain exposes it via xcrun.
local command = vim.fn.exepath("lldb-dap")
if command == "" and vim.fn.has("macunix") == 1 then
  local result = vim.system({ "xcrun", "-f", "lldb-dap" }, { text = true }):wait()
  if result.code == 0 then
    command = vim.trim(result.stdout)
  end
end

dap.adapters["lldb-dap"] = {
  type = "executable",
  command = command ~= "" and command or "lldb-dap",
}

-- LLDB sends stdout/stderr to the REPL when runInTerminal is false.
-- Keep that output visible, including after a short test run exits.
dap.listeners.after.event_initialized["config.dap.output"] = function(session)
  if
    session.config.type == "lldb-dap"
    or session.config.type == "python"
    or session.config.type == "debugpy"
    or session.config.type == "cortex-debug"
  then
    dap.repl.open({}, "belowright 12split")
  end
end

local function executable()
  local path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  if path == "" then
    return dap.ABORT
  end
  return vim.fn.fnamemodify(vim.fn.expand(path), ":p")
end

-- Project-specific executables, argument arrays, cwd and environment belong in
-- .vscode/launch.json (type: "lldb-dap").
-- Compile host tests with debug symbols (-g) and low optimization (-O0).
dap.configurations.c = {
  {
    name = "LLDB: Launch executable",
    type = "lldb-dap",
    request = "launch",
    program = executable,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
    -- Show output in the REPL for non-interactive executables.
    runInTerminal = false,
  },
}
dap.configurations.cpp = dap.configurations.c

-- Resolve workspace variables against the launch file's directory, so projects
-- work when Neovim's cwd is a subdirectory. Leave cwd itself untouched.
local function project_configs()
  local path = vim.fs.find(".vscode/launch.json", { path = vim.fn.getcwd(), upward = true })[1]
  if not path then
    return {}, nil
  end
  local root = vim.fs.dirname(vim.fs.dirname(path))
  local function resolve(value)
    if type(value) == "table" then
      for key, item in pairs(value) do
        value[key] = resolve(item)
      end
    elseif type(value) == "string" then
      value = value:gsub("%${workspaceFolder}", function()
        return root
      end)
      value = value:gsub("%${workspaceFolderBasename}", function()
        return vim.fs.basename(root)
      end)
    end
    return value
  end
  return resolve(require("dap.ext.vscode").getconfigs(path)), root
end

-- The built-in provider handles a launch.json in cwd; add ancestor discovery.
dap.providers.configs["config.dap.project"] = function()
  local configs, root = project_configs()
  return root ~= vim.fn.getcwd() and configs or {}
end

local M = {}

function M.run_tests()
  local configs = project_configs()
  local tests = vim.tbl_filter(function(config)
    return config.presentation and config.presentation.group == "test"
  end, configs)
  if #tests == 0 then
    vim.notify('No launch.json profiles with presentation.group = "test"', vim.log.levels.ERROR)
  elseif #tests == 1 then
    dap.run(tests[1])
  else
    vim.ui.select(tests, {
      prompt = "Debug test profile:",
      format_item = function(config)
        return config.name
      end,
    }, function(config)
      if config then
        dap.run(config)
      end
    end)
  end
end

vim.api.nvim_create_user_command("DapTest", M.run_tests, { desc = "Debug a project test profile from launch.json" })

return M
