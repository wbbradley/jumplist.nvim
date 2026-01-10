local config = require("jumplist.config")

local M = {}

local state = {
  buf = nil,
  win = nil,
}

local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "jumplist")
  vim.api.nvim_buf_set_name(buf, "Jumplist")
  return buf
end

local function setup_window_options(win)
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)
  vim.api.nvim_win_set_option(win, "signcolumn", "no")
  vim.api.nvim_win_set_option(win, "winfixwidth", true)
  vim.api.nvim_win_set_option(win, "wrap", false)
  vim.api.nvim_win_set_option(win, "cursorline", true)
end

function M.open()
  if M.is_open() then
    return state.win, state.buf
  end

  local opts = config.get()
  local current_win = vim.api.nvim_get_current_win()

  state.buf = create_buffer()

  if opts.position == "right" then
    vim.cmd("botright vnew")
  else
    vim.cmd("topleft vnew")
  end

  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_width(state.win, opts.width)

  setup_window_options(state.win)

  vim.api.nvim_set_current_win(current_win)

  return state.win, state.buf
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

function M.toggle()
  if M.is_open() then
    M.close()
  else
    M.open()
  end
end

function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

function M.get_win()
  return state.win
end

function M.get_buf()
  return state.buf
end

function M.focus()
  if M.is_open() then
    vim.api.nvim_set_current_win(state.win)
  end
end

return M
