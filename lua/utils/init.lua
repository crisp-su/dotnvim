local M = {}

M.core = require('utils.core')

for k, v in pairs(M.core) do
  M[k] = v
end

M.strings = require('utils.strings')
M.root = require('utils.root')
M.wk = require('utils.which-key')
M.lualine = require('utils.lualine')
M.oil = require('utils.oil')
M.toolchain = require('utils.toolchain')
M.lsp = require('utils.lsp')
M.linter = require('utils.linter')
M.formatter = require('utils.formatter')
M.python = require('utils.python')

return M
