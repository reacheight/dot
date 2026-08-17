return {
  "GustavEikaas/easy-dotnet.nvim",
  commit = "5823c50d0de015c01f591319f6e846506518165e",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("easy-dotnet").setup({
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
    })
  end,
}
