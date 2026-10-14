-- Plugin packages are installed centrally by config.pack.

-- Disabled package/configuration retained for reference:
--[[
{ -- pytest: Testing integrated in neovim with pytest
    "richardhapb/pytest.nvim",
    enabled = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {}, -- Define the options here
    config = function(_, opts)
      require("nvim-treesitter.config").setup({
        ensure_installed = { "python", "xml" },
      })

      require("pytest").setup(opts)
    end,
  }
]]

do -- nvim-neotest/neotest
  require("neotest").setup({
    adapters = {
      require("neotest-python")({
        -- Extra arguments for nvim-dap configuration
        -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
        dap = {
          justMyCode = false,
          console = "internalConsole",
          redirectOutput = true,
          -- neotest's postmortem hook needs the tracing backend on Python 3.12+.
          -- https://github.com/microsoft/debugpy/issues/1970
          env = { PYDEVD_USE_SYS_MONITORING = "0" },
        },
        -- Command line arguments for runner
        -- Can also be a function to return dynamic values
        args = function(_, position)
          local base = require("neotest-python.base")
          local python = base.get_python_command(base.get_root(position.path))
          local args = { "--log-level", "DEBUG" }
          -- Keep debugging in one process and avoid coverage tracing conflicts.
          -- These flags only exist when the corresponding pytest plugin does.
          if base.module_exists("xdist", python) then
            table.insert(args, "-n0")
          end
          if base.module_exists("pytest_cov", python) then
            table.insert(args, "--no-cov")
          end
          return args
        end,
        -- Runner to use. Will use pytest if available by default.
        -- Can be a function to return dynamic value.
        runner = "pytest",
        -- Let the adapter detect the activated or project virtualenv.
        -- Returns if a given file path is a test file.
        -- NB: This function is called a lot so don't perform any heavy tasks within it.
        -- is_test_file = function(file_path)
        -- ...
        -- end,
        -- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
        -- instances for files containing a parametrize mark (default: false)
        pytest_discover_instances = false,
      }),
    },
    -- See all config options with :h neotest.Config
    discovery = {
      -- Drastically improve performance in ginormous projects by
      -- only AST-parsing the currently opened buffer.
      enabled = false,
      -- Number of workers to parse files concurrently.
      -- A value of 0 automatically assigns number based on CPU.
      -- Set to 1 if experiencing lag.
      concurrent = 1,
    },
    running = {
      -- Run tests concurrently when an adapter provides multiple commands to run.
      concurrent = false,
    },
    summary = {
      -- Enable/disable animation of icons.
      animated = false,
    },
  })

  vim.keymap.set("n", "<leader>np", function()
    require("neotest").output_panel.toggle()
  end, { desc = "neo-test toggle output panel" })
  vim.keymap.set("n", "<leader>nd", function()
    require("neotest").run.run({ strategy = "dap" })
  end, { desc = "neo-test debug this test" })
  vim.keymap.set("n", "<leader>nD", function()
    require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" })
  end, { desc = "neo-test debug tests in file" })
  vim.keymap.set("n", "<leader>nR", function()
    require("neotest").run.run_last({ strategy = "dap" })
  end, { desc = "neo-test debug last run" })
  vim.keymap.set("n", "<leader>nt", function()
    require("neotest").run.run()
  end, { desc = "neo-test run this test" })
  vim.keymap.set("n", "<leader>no", function()
    require("neotest").output.open()
  end, { desc = "neo-test open float" })
  vim.keymap.set("n", "<leader>na", function()
    require("neotest").run.run(vim.fn.expand("%"))
  end, { desc = "neo-test run all tests in file" })
end
