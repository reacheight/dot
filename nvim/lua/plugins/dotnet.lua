return {
  "GustavEikaas/easy-dotnet.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("easy-dotnet").setup({
      lsp = {
        easy_dotnet_extension_enabled = true,
        enhanced_rename = true,
      },
      test_runner = {
        auto_start_testrunner = false,
        viewmode = "split",
      },
      picker = "snacks",
    })
  end,
}
