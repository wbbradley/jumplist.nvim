local config = require("jumplist.config")
local window = require("jumplist.window")

local M = {}

local ns_id = vim.api.nvim_create_namespace("jumplist")

local function get_line_content(bufnr, lnum)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return ""
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)
  if #lines > 0 then
    return vim.trim(lines[1])
  end
  return ""
end

local function shorten_path(path, max_width)
  if #path <= max_width then
    return path
  end
  local filename = vim.fn.fnamemodify(path, ":t")
  if #filename >= max_width then
    return string.sub(filename, 1, max_width - 3) .. "..."
  end
  local remaining = max_width - #filename - 4
  if remaining > 0 then
    local dir = vim.fn.fnamemodify(path, ":h")
    return ".../" .. string.sub(dir, -remaining) .. "/" .. filename
  end
  return filename
end

local function format_entry(entry, index, current_idx, opts)
  local bufnr = entry.bufnr
  local lnum = entry.lnum
  local col = entry.col

  local filename = ""
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == "" then
      filename = "[No Name]"
    else
      filename = vim.fn.fnamemodify(filename, ":~:.")
    end
  else
    filename = "[Invalid]"
  end

  local marker = index == current_idx and ">" or " "
  local short_name = shorten_path(filename, opts.width - 10)
  local line = string.format("%s %3d %s:%d", marker, index, short_name, lnum)

  return line
end

function M.refresh()
  if not window.is_open() then
    return
  end

  local buf = window.get_buf()
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local opts = config.get()
  local jumplist, current_idx = unpack(vim.fn.getjumplist())

  current_idx = current_idx + 1

  local lines = {}
  local highlights = {}

  table.insert(lines, "Jumplist (" .. #jumplist .. " entries)")
  table.insert(lines, string.rep("-", opts.width - 2))

  local start_idx = math.max(1, #jumplist - opts.max_entries + 1)

  for i = start_idx, #jumplist do
    local entry = jumplist[i]
    local line = format_entry(entry, i, current_idx, opts)
    table.insert(lines, line)

    if i == current_idx then
      table.insert(highlights, { line = #lines - 1, col_start = 0, col_end = -1 })
    end
  end

  if #jumplist == 0 then
    table.insert(lines, "")
    table.insert(lines, "  (empty)")
  end

  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns_id, "CursorLine", hl.line, hl.col_start, hl.col_end)
  end
end

function M.get_entry_at_cursor()
  local buf = window.get_buf()
  if not buf then
    return nil
  end

  local win = window.get_win()
  if not win then
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(win)
  local line_num = cursor[1]

  if line_num <= 2 then
    return nil
  end

  local opts = config.get()
  local jumplist, _ = unpack(vim.fn.getjumplist())
  local start_idx = math.max(1, #jumplist - opts.max_entries + 1)
  local entry_idx = start_idx + (line_num - 3)

  if entry_idx >= 1 and entry_idx <= #jumplist then
    return jumplist[entry_idx], entry_idx
  end

  return nil
end

return M
