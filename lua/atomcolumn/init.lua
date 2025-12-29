local M = {}

M.config = {
  sep = "│",
  sign = nil,
  ft_ignore = nil,
  bt_ignore = nil,
  hl = {
    sign = nil,
    lnum = nil,
    sep = nil,
  },
}

function M.setup(opts)
  opts = vim.tbl_extend("force", M.config, opts or {})

  require("atomcolumn.statuscol").setup(opts)
end

return M
