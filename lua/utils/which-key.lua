--- @alias WkMappingLhs string
--- @alias WkMappingRhs string | function
--- @alias WkMappingProps table

local M = {}

M._wk = nil --- @type table -- which-key backup
M._add = nil --- @type fun(spec: table, opts?: table): nil?

function M.setup_pre()
  M._wk = require('which-key')

  M.override_wk_fields()
  M.override_wk_add()
  M.override_wk_show()
  M.set_wk_plugins()
end

function M.setup_post() M.set_autocmds() end

--- @alias WkEntryId number
--- @alias WkEntryTs number
--- @alias WkEntrySpec table
--- @alias WkEntryOpts table?
--- @alias WkEntryKeys table
--- @alias WkEntryResolvedItem table
--- @alias WkEntryResolved table<string, WkEntryResolvedItem>

local wk_entry_resolved_item_extras = { '_lhs', '_rhs' }

--- @class WkEntry
--- @field id WkEntryId
--- @field ts WkEntryTs
--- @field spec WkEntrySpec
--- @field opts WkEntryOpts
--- @field keys WkEntryKeys
--- @field resolved WkEntryResolved

--- @alias HistoryStore WkEntry[]
--- @alias HistoryIndex table<string, WkEntry[]>

--- @class History
--- @field store HistoryStore
--- @field index HistoryIndex
M.history = {
  store = {},
  index = {},

  _id_counter = 0,
}

--- @param spec WkEntrySpec
--- @param prefix? string
--- @return string[]
local function extract_lhs(spec, prefix)
  prefix = prefix or ''

  local keys = {}

  if type(spec) ~= 'table' then
    return keys
  end

  local lhs = spec[1]
  local current_lhs = nil
  local is_mapping = type(lhs) == 'string'

  if is_mapping then
    current_lhs = prefix .. lhs
    table.insert(keys, current_lhs)
  end

  local child_prefix = spec.prefix or current_lhs or prefix

  for _, val in ipairs(spec) do
    if type(val) == 'table' then
      local children = extract_lhs(val, child_prefix)
      vim.list_extend(keys, children)
    end
  end

  return keys
end

--- @param spec WkEntrySpec
--- @param opts WkEntryOpts
--- @param prefix? string
--- @param inherited? table
--- @return table
local function resolve_spec(spec, opts, prefix, inherited)
  opts = opts or {}
  prefix = prefix or ''
  inherited = inherited or {}

  local results = {}

  local current_metadata = {}

  for k, v in pairs(inherited) do
    if type(k) == 'string' then
      current_metadata[k] = v
    end
  end

  for k, v in pairs(spec) do
    if type(k) == 'string' and k ~= 'prefix' then
      current_metadata[k] = v
    end
  end

  local lhs = spec[1]
  local rhs = spec[2]

  local current_lhs = nil
  local is_mapping = type(lhs) == 'string'

  if is_mapping then
    current_lhs = prefix .. lhs

    local entry = vim.tbl_extend('force', opts, current_metadata)

    entry._lhs = lhs
    entry._rhs = rhs

    results[current_lhs] = entry
  end

  local child_prefix = spec.prefix or current_lhs or prefix

  for _, val in ipairs(spec) do
    if type(val) == 'table' then
      local children = resolve_spec(val, opts, child_prefix, current_metadata)
      results = vim.tbl_extend('force', results, children)
    end
  end

  return results
end

--- @param resvi WkEntryResolvedItem
--- @return WkMappingProps
function M.resolved_item_to_props(resvi)
  for _, key in ipairs(wk_entry_resolved_item_extras) do
    resvi[key] = nil
  end

  return resvi
end

--- @param resvi WkEntryResolvedItem
--- @return WkEntryResolvedItem
function M.resolved_item_to_extras(resvi)
  local extras = {}

  for _, key in ipairs(wk_entry_resolved_item_extras) do
    if resvi[key] ~= nil then
      extras[key] = resvi[key]
    end
  end

  return extras
end

--- @param entry WkEntry
--- @param lhs WkMappingLhs
--- @return WkEntryResolvedItem?
function M.get_entry_resolved_item(entry, lhs)
  if not entry or not entry.resolved then
    return nil
  end

  return entry.resolved[lhs]
end

--- @param entry WkEntry
--- @param lhs WkMappingLhs
--- @param prop string
--- @return any
function M.get_entry_prop_value(entry, lhs, prop)
  local resvi = M.get_entry_resolved_item(entry, lhs)

  if not resvi then
    return nil
  end

  return M.resolved_item_to_props(resvi[prop])
end

--- @param entry WkEntry
function M.history:insert(entry) table.insert(self.store, entry) end

--- @param id WkEntryId
--- @return WkEntry?
function M.history:find_by_id(id)
  local entry = vim.iter(self.store):find(function(e) return e.id == id end)

  return entry
end

--- @param id WkEntryId
--- @return WkEntry?
function M.history:remove_by_id(id)
  local target_entry = nil
  local history_idx = -1

  for i, entry in ipairs(self.store) do
    if entry.id == id then
      target_entry = entry
      history_idx = i
      break
    end
  end

  if not target_entry then
    return nil
  end

  local entry = table.remove(self.store, history_idx)

  for _, lhs in ipairs(target_entry.keys) do
    local list = self.index[lhs]
    if list then
      for i = #list, 1, -1 do
        if list[i].id == id then
          table.remove(list, i)
        end
      end

      if #list == 0 then
        self.index[lhs] = nil
      end
    end
  end

  return entry
end

--- @param lhs WkMappingLhs
--- @param offset? number
--- @return WkEntry?
function M.history:find_by_lhs_offset(lhs, offset)
  offset = offset or 0

  local list = self.index[lhs]
  if not list or #list == 0 then
    return nil
  end

  local target_idx = #list + offset

  if target_idx < 1 then
    return nil
  end

  local entry = list[target_idx]

  return entry
end

--- @param lhs WkMappingLhs
--- @return WkEntry[]?
function M.history:find_all_by_lhs(lhs) return self.index[lhs] end

--- @param query_props WkMappingProps
--- @return { lhs: string, entry: WkEntry, props: table }[]
function M.history:find_all_latest_by_props(query_props)
  local results = {}

  --- @diagnostic disable-next-line: param-type-mismatch
  for lhs, list in pairs(self.index) do
    local latest_entry = list[#list]
    local actual_props = latest_entry.resolved[lhs]

    if actual_props then
      local is_match = true

      for k, v in pairs(query_props) do
        if actual_props[k] ~= v then
          is_match = false
          break
        end
      end

      if is_match then
        table.insert(results, {
          lhs = lhs,
          entry = latest_entry,
          props = actual_props,
        })
      end
    end
  end

  -- table.sort(entries, function(a, b)
  --   return a.lhs < b.lhs
  -- end)

  return results
end

--- @return { lhs: string, entry: WkEntry, props: table }[]
function M.history:find_all_refresh_enabled() return self:find_all_latest_by_props({ refresh = true }) end

function M.history:cleanup_history()
  local seen = {}
  local new_history = {}
  local new_index = {}

  for _, entry in ipairs(self.store) do
    local fingerprint = vim.inspect({ entry.spec, entry.opts })

    if not seen[fingerprint] then
      seen[fingerprint] = true

      table.insert(new_history, entry)

      for _, k in ipairs(entry.keys) do
        new_index[k] = new_index[k] or {}
        table.insert(new_index[k], entry)
      end
    end
  end

  self.store = new_history
  self.index = new_index
end

--- @param mode string | string[]
--- @param lhs WkMappingLhs
local function delete_keymap_only(mode, lhs)
  local modes = type(mode) == 'table' and mode or { mode }
  for _, m in ipairs(modes) do
    pcall(vim.api.nvim_del_keymap, m, lhs)
  end
end

--- @param spec WkEntrySpec
--- @param opts WkEntryOpts
--- @return WkEntry
function M.add(spec, opts)
  M.history._id_counter = M.history._id_counter + 1

  local affected_keys = extract_lhs(spec)
  local resolved = resolve_spec(spec, opts)

  local entry = {
    id = M.history._id_counter,
    ts = os.time(),
    spec = vim.deepcopy(spec),
    opts = vim.deepcopy(opts), --- @diagnostic disable-line: param-type-mismatch
    keys = affected_keys,
    resolved = resolved,
  } --- @type WkEntry

  M.history:insert(entry)

  for _, lhs in ipairs(affected_keys) do
    M.history.index[lhs] = M.history.index[lhs] or {}
    local list = M.history.index[lhs]
    table.insert(list, entry)
  end

  M._add(spec, opts)

  return entry
end

--- @param mode string | string[]
function M.remove(mode, lhs)
  mode = type(mode) == 'table' and mode or { mode } --- @as string[]
  local entry = M._add({ lhs, mode = mode, desc = 'which_key_ignore' })
  delete_keymap_only(mode, lhs)
  return entry
end

--- @param lhs WkMappingLhs
--- @return WkMappingRhs?
function M.get_rhs_by_lhs(lhs)
  local entry = M.history:find_by_lhs_offset(lhs, 0)

  if not entry then
    return nil
  end

  local rhs = M.get_entry_resolved_item(entry, lhs)._rhs
  local rhs_t = type(rhs)

  if rhs_t ~= 'string' and rhs_t ~= 'function' then
    return nil
  end

  return rhs
end

--- @param entry WkEntry
--- @return WkEntry?
function M.reproduce_entry(entry)
  if not entry or not entry.spec then
    return nil
  end

  return M.add(entry.spec, entry.opts)
end

--- @param entry WkEntry
--- @return WkEntry?
function M.reapply_entry(entry)
  M.history:remove_by_id(entry.id)
  local new_entry = M.add(entry.spec, entry.opts)

  return new_entry
end

--- @param lhs WkMappingLhs
--- @return WkEntry?
function M.reapply_lhs(lhs)
  local entry = M.history:find_by_lhs_offset(lhs, 0)

  if not entry then
    return nil
  end

  M.history:remove_by_id(entry.id)
  local new_entry = M.add(entry.spec, entry.opts)

  return new_entry
end

function M.refresh()
  local results = M.history:find_all_refresh_enabled()
  local done = {}

  for _, res in ipairs(results) do
    local entry = res.entry
    if not done[entry.id] then
      done[entry.id] = true
      M.reapply_entry(entry)
    end
  end
end

function M.set_autocmds()
  local group = vim.api.nvim_create_augroup('WhichKeyUtil', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
    group = group,
    desc = 'Refresh which-key mappings (uses history entries)',
    callback = function(args)
      local buftype = vim.bo[args.buf].buftype
      if buftype ~= '' then
        return
      end

      M.refresh()
    end,
  })
end

function M.override_wk_add()
  local wk_mappings = require('which-key.mappings')
  local wk_config = require('which-key.config')

  local old_mappings_add = wk_mappings.add
  --- @diagnostic disable-next-line: duplicate-set-field
  wk_mappings.add = function(mapping, ret, opts)
    --- @diagnostic disable-next-line: undefined-field
    if mapping.refresh == true and (type(mapping.group) == 'string' or type(mapping.group) == 'function') then
      return
    end

    if mapping.cond ~= nil and mapping.lhs ~= nil then
      -- Remove disabled keymap
      if mapping.cond == false or ((type(mapping.cond) == 'function') and not mapping.cond()) then
        M.remove(mapping.mode or 'n', mapping.lhs)
      end
    end

    old_mappings_add(mapping, ret, opts)
  end

  if not M._add then
    M._add = wk_config.add
  end
  wk_config.add = M.add
end

function M.override_wk_fields()
  local wk_mappings = require('which-key.mappings')

  wk_mappings.fields = vim.tbl_extend('force', wk_mappings.fields, {
    refresh = {},
  })
end

function M.override_wk_show()
  local wk_win = require('which-key.win')

  local old_show = wk_win.show
  wk_win.show = function(self, opts)
    -- M.refresh()
    old_show(self, opts)
  end
end

function M.set_wk_plugins() package.loaded['which-key.plugins.presets'] = require('d.which_key_presets_plugin') end

return M
