local M = {}

local ts_action_state = require('utils').lazy_require('telescope.actions.state')

local function telescope_title() return 'Telescope' end

local function prompt_title()
  local bufnr = vim.api.nvim_get_current_buf()
  local picker = ts_action_state.get_current_picker(bufnr)
  return picker.prompt_title
end

M.sections = {
  lualine_a = { telescope_title },
  lualine_b = { prompt_title },
}

M.filetypes = { 'TelescopePrompt' }

return M
