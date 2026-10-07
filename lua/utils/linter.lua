local M = {}

local toolchain = require('utils.toolchain')

--- Resolve the executable name of an nvim-lint linter.
--- @param name string
--- @return string
local function command_of(name)
  local ok, lint = pcall(require, 'lint')

  if ok and type(lint.linters[name]) == 'table' then
    local cmd = lint.linters[name].cmd

    if type(cmd) == 'string' then
      return cmd
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

--- Keep only linters provided by the environment (not the Nixvim fallback).
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

--- Set `lint.linters_by_ft[ft]` to only the environment-provided linters.
--- @param ft string
--- @param names string[]
function M.set_external_linters(ft, names)
  local ok, lint = pcall(require, 'lint')

  if not ok then
    return
  end

  lint.linters_by_ft[ft] = M.external(names)
end

return M
