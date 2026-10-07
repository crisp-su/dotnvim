local M = {}

local toolchain = require('utils.toolchain')

--- Resolve the executable name of a conform formatter.
--- @param name string
--- @return string
local function command_of(name)
  local ok, formatters = pcall(require, 'conform.formatters')

  if ok then
    -- `conform.formatters` lazily requires the formatter module on index,
    -- which raises for names that are not conform formatters.
    local indexed, formatter = pcall(function()
      return formatters[name]
    end)

    if indexed and type(formatter) == 'table' and type(formatter.command) == 'string' then
      return formatter.command
    end
  end

  return name
end

local function is_executable(name)
  return toolchain.exe_available(command_of(name))
end

local function is_fallback(name)
  return toolchain.exe_is_fallback(command_of(name))
end

--- Keep only formatters provided by the environment (not the Nixvim fallback).
--- @param names string[] candidates in priority order
--- @return string[]
function M.external(names)
  local result = {}

  for _, name in ipairs(names) do
    if is_executable(name) and not is_fallback(name) then
      table.insert(result, name)
    end
  end

  return result
end

--- Pick a single formatter for conform `formatters_by_ft`:
--- environment-provided candidates win (in order), otherwise the default
--- (last entry of `names`) is used when available.
--- @param names string[] candidates in priority order, last one is the default
--- @return string[]
function M.pick(names)
  local external = M.external(names)

  if #external > 0 then
    return { external[1] }
  end

  local default = names[#names]

  if default ~= nil and is_executable(default) then
    return { default }
  end

  return {}
end

return M
