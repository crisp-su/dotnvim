local M = {}

--- Bin directories of all fallback packages appended to the end of `PATH`.
--- Populated from the merged `extraPackagesAfter` in `config/luaset.nix`.
M.fallback_bins = {}

--- @param exe string executable name or absolute path
--- @return boolean
function M.exe_available(exe)
  return vim.fn.executable(exe) == 1
end

--- Whether the executable resolves to a Nixvim-provided fallback binary,
--- i.e. it is not provided by the environment (devshell, system, etc.).
--- @param exe string
--- @return boolean
function M.exe_is_fallback(exe)
  local path = vim.fn.exepath(exe)

  if path == '' then
    return false
  end

  path = vim.fs.normalize(path)

  for _, dir in ipairs(M.fallback_bins) do
    if path:sub(1, #dir + 1) == dir .. '/' then
      return true
    end
  end

  return false
end

return M
