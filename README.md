# atomcolumn
Minimalistic statuscolumn for Neovim.

## Install (lazy.nvim)

```lua
{
  "iAmFoxik/atomcolumn",
  opts = {
    sep = "│",
    sign = nil,
    ft_ignore = nil,
    bt_ignore = nil,
    current_line = false,
    hl = {
      sign = nil,
      lnum = nil,
      sep = nil,
      current = nil,
    },
  },
}
```

## Options
> All options are optional

- **sep** `string`
  Separator character between the line number and the buffer text.
  Default: `"│"`

- **sign** `string`
  Value for Neovim's `signcolumn` option.
  Controls the visibility and width of the sign column (git, diagnostics, dap, etc).
  Default: `"yes:1"`

- **ft_ignore** `table<string>`
  List of filetypes where the status column will be disabled.
  Useful for special buffers like Telescope, help pages, dashboards, etc.
  Example: `{ "neo-tree", "TelescopePreview" }`

- **bt_ignore** `table<string>`
  List of buffer types where the status column will be disabled.
  Common values: `{ "nofile", "prompt", "terminal" }`

- **current_line** `bool`
  Highlight the current line number.
  Default: `false`

- **hl** `table`
  Highlight configuration for different parts of the status column.

  - **hl.sign** `string`
    Highlight group for the sign column (`%s`).
    Default: `LineNr`

  - **hl.lnum** `string`
    Highlight group for the line number.
    Default: `LineNr`

  - **hl.sep** `string`
    Highlight group for the separator character.
    Default: `LineNr`

  - **hl.current** `string`
    Highlight group for the current line number.
    Default: `Normal`

## Bugs
- The diagnostic highlight does not work correctly with `set relativenumber`.
