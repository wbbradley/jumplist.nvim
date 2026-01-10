local M = {}

local config = require("jumplist.config")
local window = require("jumplist.window")
local render = require("jumplist.render")

local augroup = nil

local function setup_keymaps(buf)
  local opts = { buffer = buf, noremap = true, silent = true }

  vim.keymap.set("n", "<CR>", function()
    local entry, idx = render.get_entry_at_cursor()
    if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      local current_win = nil
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if win ~= window.get_win() then
          current_win = win
          break
        end
      end
      if current_win then
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_buf(current_win, entry.bufnr)
        vim.api.nvim_win_set_cursor(current_win, { entry.lnum, entry.col })
      end
    end
  end, vim.tbl_extend("force", opts, { desc = "Jump to entry" }))

  vim.keymap.set("n", "o", function()
    local entry, idx = render.get_entry_at_cursor()
    if entry and entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
      window.close()
      vim.api.nvim_set_current_buf(entry.bufnr)
      vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col })
    end
  end, vim.tbl_extend("force", opts, { desc = "Jump to entry and close" }))

  vim.keymap.set("n", "q", function()
    window.close()
  end, vim.tbl_extend("force", opts, { desc = "Close jumplist" }))

  vim.keymap.set("n", "r", function()
    render.refresh()
  end, vim.tbl_extend("force", opts, { desc = "Refresh jumplist" }))
end

local function setup_autocmds()
  if augroup then
    vim.api.nvim_del_augroup_by_id(augroup)
  end

  augroup = vim.api.nvim_create_augroup("Jumplist", { clear = true })

  local opts = config.get()

  if opts.auto_update then
    vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
      group = augroup,
      callback = function()
        if window.is_open() then
          vim.schedule(render.refresh)
        end
      end,
    })
  end

  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    callback = function(args)
      local win = window.get_win()
      if win and tostring(win) == args.match then
        window.close()
      end
    end,
  })
end

local function setup_commands()
  vim.api.nvim_create_user_command("Jumplist", function()
    M.toggle()
  end, { desc = "Toggle jumplist window" })

  vim.api.nvim_create_user_command("JumplistOpen", function()
    M.open()
  end, { desc = "Open jumplist window" })

  vim.api.nvim_create_user_command("JumplistClose", function()
    M.close()
  end, { desc = "Close jumplist window" })

  vim.api.nvim_create_user_command("JumplistRefresh", function()
    M.refresh()
  end, { desc = "Refresh jumplist display" })
end

function M.setup(opts)
  config.setup(opts)
  setup_autocmds()
  setup_commands()
end

function M.open()
  local win, buf = window.open()
  if buf then
    setup_keymaps(buf)
    render.refresh()
  end
end

function M.close()
  window.close()
end

function M.toggle()
  if window.is_open() then
    window.close()
  else
    M.open()
  end
end

function M.refresh()
  render.refresh()
end

function M.is_open()
  return window.is_open()
end

return M
