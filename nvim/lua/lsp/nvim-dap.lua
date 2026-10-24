local function open_console_only()
  local dapui = require("dapui")
  dapui.close()
  dapui.open({ layout = 1 })
end
local function open_full_dap()
  local dapui = require("dapui")
  dapui.close()
  dapui.open()
end

return {
  "mfussenegger/nvim-dap",
  enabled = true,
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dap.listeners.after.event_stopped["dap_ui"] = function()
      open_full_dap()
    end

    dap.listeners.on_session["dap_ui"] = function(_, new)
      if new == nil then
        dapui.close()
      else
        open_console_only()
      end
    end

    vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

    vim.keymap.set("n", "<F5>", function()
      open_console_only()
      dap.continue()
    end, { desc = "Start/continue debugging" })

    vim.keymap.set("n", "<leader>ds", function()
      open_console_only()
      dap.continue()
    end, { desc = "Start/continue debugging" })

    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })

    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })

    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })

    vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })

    vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle DAP REPL" })

    vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Go down stack frame" })
    vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Go up stack frame" })
    vim.keymap.set("n", "<F2>", require("dap.ui.widgets").hover, {})

    vim.fn.sign_define("DapBreakpoint", { text = "🤡", texthl = "", linehl = "DapBreakpoint", numhl = "" })
    vim.fn.sign_define("DapStopped", { text = "󰳟", texthl = "", linehl = "DapStopped", numhl = "" })
    vim.api.nvim_set_hl(0, "DapStopped", { default = true, link = "Visual" })
  end,
  dependencies = {
    {
      "rcarriga/nvim-dap-ui",
      config = function()
        require("dapui").setup({
          mappings = {
            expand = { "<CR>" },
          },
          layouts = {
            {
              elements = { { id = "console", size = 1 } },
              size = 80,
              position = "right",
            },
            {
              elements = {
                "watches",
                "breakpoints",
                "stacks",
              },
              size = 10,
              position = "bottom",
            },
            {
              elements = { { id = "scopes", size = 1 } },
              size = 10,
              position = "bottom",
            },
          },
          controls = { element = "scopes" },
        })
      end,
    },
  },
}
