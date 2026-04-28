-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- delete default terminal keymap and replace it with comment toggling
vim.api.nvim_del_keymap("n", "<c-/>")
vim.api.nvim_del_keymap("n", "<c-_>")
vim.api.nvim_del_keymap("t", "<C-/>")
vim.api.nvim_del_keymap("t", "<C-_>")

local line_rhs = function()
  return require("vim._comment").operator() .. "_"
end

vim.keymap.set("n", "<c-_>", line_rhs, { expr = true, desc = "Toggle comment line" })
vim.keymap.set("n", "<c-/>", line_rhs, { expr = true, desc = "Toggle comment line" })

local textobject_rhs = function()
  require("vim._comment").textobject()
end
vim.keymap.set({ "o" }, "<c-_>", textobject_rhs, { desc = "Comment textobject" })
vim.keymap.set({ "o" }, "<c-/>", textobject_rhs, { desc = "Comment textobject" })

local operator_rhs = function()
  return require("vim._comment").operator()
end
vim.keymap.set("x", "<c-_>", operator_rhs, { expr = true, desc = "Toggle comment" })
vim.keymap.set("x", "<c-/>", operator_rhs, { expr = true, desc = "Toggle comment" })
