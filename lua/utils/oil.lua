local M = {}

local root = require('utils.root')

local TAB_IS_OIL = '__oil_tab'
local TAB_ORIGIN_TAB = '__oil_prev_tab'
local TAB_ORIGIN_WIN = '__oil_prev_win'

local SETUP_DONE_KEY = '__oil_setup'
local DETAILS_ENABLED_KEY = '__oil_details_enabled'

local PREVIEW_MAX_BYTES = 1024 * 1024

local DEFAULT_COLUMNS = {
  'icon',
}

local DETAIL_COLUMNS = {
  'icon',
  'permissions',
  'size',
  'mtime',
}

local function oil() return require('oil') end

local function actions() return require('oil.actions') end

local function details_enabled() return vim.g[DETAILS_ENABLED_KEY] == true end

local function oil_columns()
  if details_enabled() then
    return DETAIL_COLUMNS
  end
  return DEFAULT_COLUMNS
end

local function apply_oil_columns() oil().set_columns(oil_columns()) end

local function format_dir_for_winbar(dir)
  if not dir or dir == '' then
    return ''
  end

  if dir ~= '/' and dir:sub(-1) == '/' then
    dir = dir:sub(1, -2)
  end

  dir = vim.fn.fnamemodify(dir, ':~')
  return dir:gsub('%%', '%%%%')
end

local function tab_get_var(tab, key)
  local ok, value = pcall(vim.api.nvim_tabpage_get_var, tab, key)
  return ok and value or nil
end

local function tab_del_var(tab, key) pcall(vim.api.nvim_tabpage_del_var, tab, key) end

local function is_blank_scratch(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  if vim.api.nvim_buf_get_name(buf) ~= '' then
    return false
  end
  if vim.bo[buf].buftype ~= '' then
    return false
  end
  if vim.bo[buf].modified then
    return false
  end
  return true
end

local function tab_has_oil_window(tab)
  if not vim.api.nvim_tabpage_is_valid(tab) then
    return false
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'oil' then
      return true
    end
  end

  return false
end

local function close_tab(tab)
  if not vim.api.nvim_tabpage_is_valid(tab) then
    return
  end

  if vim.api.nvim_tabpage_close then
    local ok = pcall(vim.api.nvim_tabpage_close, tab, false)
    if ok then
      return
    end
  end

  local tabnr = vim.api.nvim_tabpage_get_number(tab)
  vim.cmd(string.format('%dtabclose', tabnr))
end

local function delete_if_unused_blank_scratch(buf)
  if not is_blank_scratch(buf) then
    return
  end
  if #vim.fn.win_findbuf(buf) > 0 then
    return
  end

  pcall(vim.api.nvim_buf_delete, buf, { force = true })
end

local function resolve_origin()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local current_win = vim.api.nvim_get_current_win()

  if vim.t[TAB_IS_OIL] ~= true then
    return current_tab, current_win
  end

  local origin_tab = vim.t[TAB_ORIGIN_TAB]
  if not (origin_tab and vim.api.nvim_tabpage_is_valid(origin_tab) and origin_tab ~= current_tab) then
    return current_tab, current_win
  end

  local origin_win = vim.t[TAB_ORIGIN_WIN]
  if
    origin_win
    and vim.api.nvim_win_is_valid(origin_win)
    and vim.api.nvim_win_get_tabpage(origin_win) == origin_tab
  then
    return origin_tab, origin_win
  end

  return origin_tab, nil
end

local function resolve_target_tab(current_tab, preferred_tab)
  if preferred_tab and vim.api.nvim_tabpage_is_valid(preferred_tab) and preferred_tab ~= current_tab then
    return preferred_tab
  end

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if tab ~= current_tab then
      return tab
    end
  end

  return nil
end

local function join_path(dir, name)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(dir, name)
  end
  if dir:sub(-1) == '/' then
    return dir .. name
  end
  return dir .. '/' .. name
end

local function is_stray_oil_tab(tab)
  if not vim.api.nvim_tabpage_is_valid(tab) then
    return false
  end
  if tab_get_var(tab, TAB_IS_OIL) ~= true then
    return false
  end
  if tab_has_oil_window(tab) then
    return false
  end

  local wins = vim.api.nvim_tabpage_list_wins(tab)
  if #wins ~= 1 then
    return false
  end

  local buf = vim.api.nvim_win_get_buf(wins[1])
  return is_blank_scratch(buf)
end

local function cleanup_oil_tabs()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if tab_get_var(tab, TAB_IS_OIL) == true and not tab_has_oil_window(tab) then
      if is_stray_oil_tab(tab) then
        vim.schedule(function()
          if is_stray_oil_tab(tab) then
            pcall(close_tab, tab)
          end
        end)
      else
        tab_del_var(tab, TAB_IS_OIL)
        tab_del_var(tab, TAB_ORIGIN_TAB)
        tab_del_var(tab, TAB_ORIGIN_WIN)
      end
    end
  end
end

local function origin_buf()
  if vim.t[TAB_IS_OIL] ~= true then
    return nil
  end

  local origin_win = vim.t[TAB_ORIGIN_WIN]
  if origin_win and vim.api.nvim_win_is_valid(origin_win) then
    return vim.api.nvim_win_get_buf(origin_win)
  end

  local origin_tab = vim.t[TAB_ORIGIN_TAB]
  if origin_tab and vim.api.nvim_tabpage_is_valid(origin_tab) then
    local wins = vim.api.nvim_tabpage_list_wins(origin_tab)
    if wins[1] then
      return vim.api.nvim_win_get_buf(wins[1])
    end
  end

  return nil
end

local function parent_dir_for_buf(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return nil
  end
  -- Skip non-file buffers (oil://, term://, fugitive://, etc.).
  if name:find('://', 1, true) then
    return nil
  end

  if vim.fs and vim.fs.dirname then
    return vim.fs.dirname(name)
  end
  return vim.fn.fnamemodify(name, ':h')
end

local function open_tab(dir)
  if not dir or dir == '' then
    return
  end

  M.setup()
  local origin_tab, origin_win = resolve_origin()

  vim.cmd.tabnew()
  local tabnew_buf = vim.api.nvim_get_current_buf()
  vim.t[TAB_IS_OIL] = true
  vim.t[TAB_ORIGIN_TAB] = origin_tab
  vim.t[TAB_ORIGIN_WIN] = origin_win

  -- oil.open does not guarantee a callback; schedule cleanup unconditionally.
  oil().open(dir)
  vim.schedule(function()
    delete_if_unused_blank_scratch(tabnew_buf)
    cleanup_oil_tabs()
  end)
end

function M.setup()
  if vim.g[SETUP_DONE_KEY] then
    return
  end
  vim.g[SETUP_DONE_KEY] = true

  local group = vim.api.nvim_create_augroup('OilUtil', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'WinEnter', 'WinClosed', 'TabEnter' }, {
    group = group,
    callback = cleanup_oil_tabs,
  })

  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'oil',
    callback = apply_oil_columns,
  })

  vim.schedule(cleanup_oil_tabs)
end

function M.open_root_tab()
  local buf = origin_buf()
  open_tab(buf and root.get({ buf = buf }) or root())
end

function M.open_cwd_tab() open_tab(vim.uv.cwd() or root()) end

function M.open_parent_tab()
  local buf = origin_buf() or vim.api.nvim_get_current_buf()
  local dir = parent_dir_for_buf(buf)
  open_tab(dir or vim.uv.cwd() or root())
end

function M.select()
  local entry = oil().get_cursor_entry()
  if vim.t[TAB_IS_OIL] ~= true or not entry or entry.type == 'directory' then
    actions().select.callback()
    return
  end

  local oil_tab = vim.api.nvim_get_current_tabpage()
  local target_tab = resolve_target_tab(oil_tab, vim.t[TAB_ORIGIN_TAB])
  local dir = oil().get_current_dir()
  if not (target_tab and dir and entry.name and entry.name ~= '') then
    actions().select.callback()
    return
  end

  local target_win = vim.t[TAB_ORIGIN_WIN]
  local path = join_path(dir, entry.name)

  vim.api.nvim_set_current_tabpage(target_tab)
  if
    target_win
    and vim.api.nvim_win_is_valid(target_win)
    and vim.api.nvim_win_get_tabpage(target_win) == target_tab
  then
    vim.api.nvim_set_current_win(target_win)
  end

  vim.cmd.edit(vim.fn.fnameescape(path))
  close_tab(oil_tab)
end

function M.close()
  if vim.t[TAB_IS_OIL] ~= true then
    actions().close.callback()
    return
  end

  local wins = vim.api.nvim_tabpage_list_wins(0)
  if #wins > 1 then
    vim.cmd.close()
  else
    vim.cmd.tabclose()
  end
end

function M.toggle_details()
  vim.g[DETAILS_ENABLED_KEY] = not details_enabled()
  apply_oil_columns()
end

function M.disable_preview(filename) return vim.fn.getfsize(filename) > PREVIEW_MAX_BYTES end

function M.winbar()
  local dir = oil().get_current_dir(0) or vim.uv.cwd() or ''
  dir = format_dir_for_winbar(dir)

  if dir == '' then
    return ' Oil'
  end

  return string.format(' Oil %s', dir)
end

function M.is_always_hidden(name, _) return name == '.DS_Store' end

return M
