--- This module is a rewritten version of `LazyVim.lualine`.
--- REF: https://github.com/LazyVim/LazyVim/blob/v15.13.0/lua/lazyvim/util/lualine.lua

--- @class LualineUtil
local M = {}

local status_colors = {
  ok = 'DiagnosticOk',
  error = 'DiagnosticError',
  pending = 'DiagnosticWarn',
}

--- @param name string
--- @return string?
local function get_color(name)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local color = hl.fg or hl.foreground
  if color then
    return string.format('#%06x', color)
  end
end

--- @param icon string
--- @param status_fn fun(): nil | "ok" | "error" | "pending"
function M.status(icon, status_fn)
  return {
    function() return icon end,
    cond = function() return status_fn() ~= nil end,
    color = function()
      local s = status_fn() or 'ok'
      return { fg = get_color(status_colors[s]) }
    end,
  }
end

--- @param name string
--- @param icon? string
function M.cmp_source(name, icon)
  local started = false

  icon = icon or (name:sub(1, 1):upper())

  return M.status(icon, function()
    local ok, cmp = pcall(require, 'cmp')

    if not ok then
      return
    end

    for _, s in ipairs(cmp.core.sources or {}) do
      if s.name == name then
        if s.source:is_available() then
          started = true
        else
          return started and 'error' or nil
        end
        if s.status == s.SourceStatus.FETCHING then
          return 'pending'
        end

        return 'ok'
      end
    end
  end)
end

--- @param component any
--- @param text string
--- @param hl_group? string
--- @return string
function M.format(component, text, hl_group)
  if not hl_group or hl_group == '' then
    return text:gsub('%%', '%%%%')
  end

  component.hl_cache = component.hl_cache or {}
  local lualine_hl_group = component.hl_cache[hl_group]

  if not lualine_hl_group then
    local utils = require('lualine.utils.utils')

    local fg = get_color(hl_group)
    local bold = utils.extract_highlight_colors(hl_group, 'bold')
    local italic = utils.extract_highlight_colors(hl_group, 'italic')

    local gui = {}
    if bold then
      table.insert(gui, 'bold')
    end
    if italic then
      table.insert(gui, 'italic')
    end

    lualine_hl_group = component:create_hl({
      fg = fg,
      gui = #gui > 0 and table.concat(gui, ',') or nil,
    }, 'LU_' .. hl_group)

    component.hl_cache[hl_group] = lualine_hl_group
  end

  return component:format_hl(lualine_hl_group) .. text:gsub('%%', '%%%%') .. component:get_default_hl()
end

--- @param opts? { filetype_icon?: boolean, modified_sign?: string, readonly_icon?: string, modified_hl?: string, directory_hl?: string, filename_hl?: string, length?: number }
function M.pretty_path(opts)
  opts = vim.tbl_extend('force', {
    filetype_icon = true,
    modified_sign = ' [+]',
    readonly_icon = ' 󰌾',
    modified_hl = 'MatchParen',
    directory_hl = 'NonText',
    filename_hl = 'Bold',
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then
      return ''
    end

    path = vim.fs.normalize(path)

    local root = require('utils.root').get()

    local display_path = path
    local compare_path = vim.deepcopy(path)
    local compare_root = vim.deepcopy(root)

    if vim.uv.os_uname().sysname == 'Windows_NT' then
      compare_path = compare_path:lower()
      compare_root = compare_root:lower()
    end

    if compare_path:find(compare_root, 1, true) == 1 then
      display_path = path:sub(#compare_root + 2)
    end

    local ficon = ''
    if opts.filetype_icon then
      local icon, hl = require('mini.icons').get('file', compare_path)
      ficon = M.format(self, icon, hl) .. ' '
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(display_path, '[\\/]')

    if opts.length > 0 and #parts > opts.length then
      local new_parts = { parts[1], '…' }
      for i = #parts - opts.length + 2, #parts do
        table.insert(new_parts, parts[i])
      end
      parts = new_parts
    end

    local fname = parts[#parts]
    if vim.opt_local.modified:get() then
      fname = fname .. opts.modified_sign
      parts[#parts] = M.format(self, fname, opts.modified_hl)
    else
      parts[#parts] = M.format(self, fname, opts.filename_hl)
    end

    local dir = ''
    if #parts > 1 then
      dir = table.concat(parts, sep, 1, #parts - 1) .. sep
      dir = M.format(self, dir, opts.directory_hl)
    end

    local readonly = ''
    if vim.opt_local.readonly:get() then
      readonly = M.format(self, opts.readonly_icon, opts.modified_hl)
    end

    return ficon .. dir .. parts[#parts] .. readonly
  end
end

--- @param opts? { icon?: string, color?: table }
function M.root_dir(opts)
  opts = vim.tbl_extend('force', {
    icon = '󱉭 ',
    color = { fg = get_color('Special') },
  }, opts or {})

  return {
    function()
      local root = require('utils.root').get()
      local name = vim.fs.basename(root)
      return opts.icon .. name
    end,
    color = opts.color,
  }
end

return M
