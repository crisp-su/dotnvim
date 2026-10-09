local M = {}

--- @param bufnr? number
--- @return vim.lsp.Client[]
local function buf_clients(bufnr) return vim.lsp.get_clients({ bufnr = bufnr or 0 }) end

--- @param method string
--- @return fun(): boolean
function M.has_capability(method)
  local lsp_method = method:find('/') and method or ('textDocument/' .. method)

  return function()
    local clients = buf_clients()

    return vim.iter(clients):any(function(c) return c:supports_method(lsp_method) end)
  end
end

--- @return fun(): { icon: string, hl: string }
function M.language_icon()
  return function()
    local clients = buf_clients()
    local cur_ft = vim.opt_local.filetype:get()
    local sup_fts = vim.iter(clients):map(function(c) return c.config.filetypes end):flatten():totable()

    if vim.list_contains(sup_fts, cur_ft) then
      local icon, hl = require('mini.icons').get('filetype', cur_ft)
      return { icon = icon, hl = hl }
    else
      return { icon = '', hl = '' }
    end
  end
end

return M
