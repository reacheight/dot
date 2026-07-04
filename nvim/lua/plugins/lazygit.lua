-- disables default 'editPreset' value set by snacks
return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        configure = true,
        config = {
          os = {
            editPreset = "",
          },
        },
      },
    },
  },
}
