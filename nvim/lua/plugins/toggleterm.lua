return {
  {
    "akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<c-t>]],
      direction = "horizontal",
      float_opts = {
        border = "curved",
      },
      close_on_exit = true,
      shell = vim.o.shell,
      size = 15,
      insert_mappings = true,
      terminal_mappings = true,
    },
  },
}
