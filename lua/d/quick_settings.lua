local M = {}

local utils = require('utils')
local snacks = utils.lazy_require('snacks')

function M.setup()
  snacks.toggle.dim():map('<leader>;D')
  snacks.toggle.diagnostics():map('<leader>;d')
  snacks.toggle.inlay_hints():map('<leader>;h')

  if utils.has_module('gitsigns') then
    local gs = require('gitsigns')
    local gs_config = require('gitsigns.config').config

    snacks
      .toggle({
        name = 'Current Line Blame',
        get = function() return gs_config.current_line_blame end,
        set = function(state) gs.toggle_current_line_blame(state) end,
      })
      :map('<leader>;b')
  end
end

return M
