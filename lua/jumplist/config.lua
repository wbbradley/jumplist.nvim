local M = {}

M.defaults = {
  width = 40,
  position = "right", -- "right" or "left"
  auto_update = true,
  show_line_content = true,
  max_entries = 50,
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.get()
  return M.options
end

return M
