# jumplist.nvim

A Neovim plugin that displays the jumplist (navigation stack used by `<C-o>` and `<C-i>`) in a sidebar window.

## Features

- Sidebar window showing your navigation history
- Auto-updates as you navigate through files
- Jump directly to any entry in the list
- Highlights current position in the stack

## Installation

### lazy.nvim

```lua
{
  "wbbradley/jumplist.nvim",
  lazy = true,
  cmd = { "Jumplist", "JumplistOpen" },
  keys = {
    { "<leader>j", "<cmd>Jumplist<CR>", desc = "Toggle jumplist" }
  },
  opts = {
    -- defaults shown below
    width = 40,
    position = "right",  -- "right" or "left"
    auto_update = true,
    max_entries = 50,
  }
}
```

### Manual

Add to your `init.lua`:

```lua
vim.opt.runtimepath:prepend(vim.fn.expand("~/path/to/jumplist.nvim"))
require("jumplist").setup({})
```

## Commands

| Command | Description |
|---------|-------------|
| `:Jumplist` | Toggle the jumplist window |
| `:JumplistOpen` | Open the jumplist window |
| `:JumplistClose` | Close the jumplist window |
| `:JumplistRefresh` | Refresh the display |

## Sidebar Keymaps

| Key | Description |
|-----|-------------|
| `<CR>` | Jump to entry under cursor |
| `o` | Jump to entry and close sidebar |
| `q` | Close sidebar |
| `r` | Refresh display |

## Configuration

```lua
require("jumplist").setup({
  width = 40,         -- sidebar width
  position = "right", -- "right" or "left"
  auto_update = true, -- update on cursor movement
  max_entries = 50,   -- max entries to display
})
```

## How It Works

The jumplist is Neovim's built-in navigation history. Every time you jump to a definition (`<C-]>`, `gd`), search (`/`, `?`, `*`), or use marks, your position is saved. Use `<C-o>` to go back and `<C-i>` to go forward.

This plugin visualizes that stack so you can see where you've been and jump directly to any location.
