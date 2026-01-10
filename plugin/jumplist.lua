if vim.g.loaded_jumplist then
  return
end
vim.g.loaded_jumplist = true

require("jumplist").setup({})
