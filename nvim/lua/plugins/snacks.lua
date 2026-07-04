return {
  {
    "folke/snacks.nvim",
    opts = {
      -- disables default 'editPreset' value set by snacks
      lazygit = {
        configure = true,
        config = {
          os = {
            editPreset = "",
          },
        },
      },
      -- integrates picker with easy-dotnet for creating file options
      picker = {
        sources = {
          explorer = {
            win = {
              list = {
                keys = {
                  ["A"] = "explorer_add_dotnet",
                },
              },
            },
            actions = {
              explorer_add_dotnet = function(picker)
                local dir = picker:dir()
                local easydotnet = require("easy-dotnet")

                easydotnet.create_item(dir)
              end,
            },
          },
        },
      },
    },
  },
}
