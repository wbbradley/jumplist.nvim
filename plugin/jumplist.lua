if vim.g.loaded_jumplist then
  return
end
vim.g.loaded_jumplist = true

vim.api.nvim_create_user_command("Jumplist", function()
  require("jumplist").toggle()
end, { desc = "Toggle jumplist window" })

vim.api.nvim_create_user_command("JumplistOpen", function()
  require("jumplist").open()
end, { desc = "Open jumplist window" })

vim.api.nvim_create_user_command("JumplistClose", function()
  require("jumplist").close()
end, { desc = "Close jumplist window" })

vim.api.nvim_create_user_command("JumplistRefresh", function()
  require("jumplist").refresh()
end, { desc = "Refresh jumplist display" })
