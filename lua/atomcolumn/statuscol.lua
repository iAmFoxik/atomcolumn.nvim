local M = {}

M.width_by_buf = {}

function M.update_width(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local last = vim.api.nvim_buf_line_count(bufnr)
  local last = tostring(last):len()
  M.width_by_buf[bufnr] = last

  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    vim.api.nvim_set_option_value("numberwidth", last, { win = win })
  end
end

function M.get_width()
  local bufnr = vim.api.nvim_get_current_buf()
  return M.width_by_buf[bufnr] or 1
end

function M.get_lnum()
  if vim.wo.relativenumber and vim.v.relnum ~= 0 then
    return vim.v.relnum
  end

  return vim.v.lnum
end

function M.get_sign_hl(lnum)
  local bufnr = vim.api.nvim_get_current_buf()
  local extmarks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, 0 },
    { details = true, type = "sign" }
  )

  local sign = nil
  for _, extmark in ipairs(extmarks) do
    local sign_hl = extmark[4].sign_hl_group or ""
    local priority = extmark[4].priority

    if sign_hl:match("^DiagnosticSign") then
      if sign and sign.priority < priority then
        sign = {
          sign_hl = sign_hl,
          priority = priority,
        }
      else
        sign = {
          sign_hl = sign_hl,
          priority = priority,
        }
      end
    end
  end

  return sign and sign.sign_hl or nil
end

function M.render()
  local width = M.get_width()

  if vim.v.virtnum < 0 then
    return string.rep(" ", width)
  end

  local lnum = M.get_lnum()
  local sign_hl = M.get_sign_hl(lnum)
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local lnum_hl = sign_hl or lnum == current_line and "AtomicStatusColCurrentLineNr" or "AtomicStatusColLineNr"
  local lnum_hl = "%#" .. lnum_hl .. "#"
  local pad = (" "):rep(width - #tostring(lnum))

  return pad .. lnum_hl .. lnum
  -- return ("%s%s%s%s"):format(pad, (), lnum)
end

function M.setup(opts)
  opts = opts or {}

  local sign_target = opts.hl.sign or "LineNr"
  local lnum_target = opts.hl.lnum or "LineNr"
  local sep_target = opts.hl.sep or "LineNr"

  vim.api.nvim_set_hl(0, "AtomicStatusColSign", { link = lnum_target })
  vim.api.nvim_set_hl(0, "AtomicStatusColLineNr", { link = lnum_target })
  vim.api.nvim_set_hl(0, "AtomicStatusColSep", { link = sep_target })

  if opts.current_line then
    local current_target = opts.hl.current or "Normal"
    vim.api.nvim_set_hl(0, "AtomicStatusColCurrentLineNr", { link = current_target })
  else
    vim.api.nvim_set_hl(0, "AtomicStatusColCurrentLineNr", { link = lnum_target })
  end

  local group = vim.api.nvim_create_augroup("StatusCol", { clear = true })

  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufWinEnter", "WinEnter", "TextChanged", "TextChangedI", "BufWritePost" },
    {
      callback = function()
        M.update_width()
      end,
    }
  )

  M.update_width()

  local stc = "%#AtomicStatusColSign#%s"
    .. "%{%v:lua.require('atomcolumn.statuscol').render()%}"
    .. "%#AtomicStatusColSep#"
    .. (opts.sep or "")

  vim.api.nvim_set_option_value("stc", stc, { scope = "global" })
  vim.api.nvim_set_option_value("signcolumn", opts.sign or "yes:1", { scope = "global" })

  if opts.ft_ignore then
    vim.api.nvim_create_autocmd("FileType", { group = group, pattern = opts.ft_ignore, command = "setlocal stc=" })
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      callback = function()
        if vim.tbl_contains(opts.ft_ignore, vim.api.nvim_get_option_value("ft", { scope = "local" })) then
          vim.api.nvim_set_option_value("stc", "", { scope = "local" })
        end
      end,
    })
  end

  if opts.bt_ignore then
    vim.api.nvim_create_autocmd("BufWinEnter", {
      group = group,
      callback = function()
        local bt = vim.bo.buftype
        if vim.tbl_contains(opts.bt_ignore, bt) then
          vim.opt_local.stc = ""
        end
      end,
    })
  end
end

return M
