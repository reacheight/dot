return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/snacks.nvim" },
  config = function()
    local dotnet = require("easy-dotnet")

    dotnet.setup({
      lsp = {
        easy_dotnet_extension_enabled = true,
        enhanced_rename = true,
        roslynator_enabled = false,
      },
      test_runner = {
        auto_start_testrunner = false,
        viewmode = "split",
      },
      picker = "snacks",
      debugger = {
        engine = "dncdbg",
      },
    })

    vim.keymap.set("n", "<leader>cb", function()
      dotnet.build_solution_quickfix()
    end, {
      desc = "Build solution",
    })
  end,
}
