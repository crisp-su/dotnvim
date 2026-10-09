--- This module is a rewritten version of `LazyVim.root`.
--- REF: https://github.com/LazyVim/LazyVim/blob/v15.13.0/lua/lazyvim/util/root.lua

--- @class RootUtil
--- @overload fun(): string
local M = setmetatable({}, {
  __call = function(m) return m.get() end,
})

--- @alias RootFn fun(buf: number): (string | string[])
--- @alias RootSpec string | string[] | RootFn

M.spec = { { '.git', '.envrc' }, 'lsp', 'cwd' }

--- @type table<string, RootFn>
M.detectors = {}

function M.norm(path)
  if not path or path == '' then
    return nil
  end
  path = vim.fs.normalize(path)
  local real = vim.uv.fs_realpath(path)
  return real and vim.fs.normalize(real) or path
end

function M.bufpath(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then
    return nil
  end
  return M.norm(name)
end

function M.detectors.cwd() return { M.norm(vim.uv.cwd()) } end

function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end

  local roots = {} --- @type string[]
  local clients = vim.lsp.get_clients({ bufnr = buf })

  local ignore = vim.g.root_lsp_ignore or {}
  clients = vim.tbl_filter(function(client) return not vim.tbl_contains(ignore, client.name) end, clients)

  for _, client in pairs(clients) do
    local folders = client.config.workspace_folders
    for _, folder in pairs(folders or {}) do
      roots[#roots + 1] = vim.uri_to_fname(folder.uri)
    end
    if client.root_dir then
      roots[#roots + 1] = client.root_dir
    end
  end

  return vim.tbl_filter(function(path)
    local npath = M.norm(path)
    return npath and bufpath:find(npath, 1, true) == 1
  end, roots)
end

function M.detectors.pattern(buf, patterns)
  patterns = type(patterns) == 'string' and { patterns } or patterns
  local path = M.bufpath(buf) or M.norm(vim.uv.cwd())

  local found = vim.fs.find(patterns, {
    path = path,
    upward = true,
    stop = vim.uv.os_homedir(),
  })

  return found[1] and { vim.fs.dirname(found[1]) } or {}
end

--- @param spec RootSpec
--- @return RootFn
function M.resolve(spec)
  if M.detectors[spec] then
    return M.detectors[spec]
  elseif type(spec) == 'function' then
    return spec
  end
  return function(buf) return M.detectors.pattern(buf, spec) end
end

--- @param opts? { buf?: number, spec?: RootSpec[], all?: boolean }
--- @return { spec: RootSpec, paths: string[] }[]
function M.detect(opts)
  opts = opts or {}
  opts.spec = opts.spec or vim.g.root_spec or M.spec
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local results = {}
  for _, spec in ipairs(opts.spec) do
    local paths = M.resolve(spec)(opts.buf)
    paths = type(paths) == 'table' and paths or { paths }

    local valid_paths = {}
    for _, p in ipairs(paths) do
      local np = M.norm(p)
      if np and not vim.tbl_contains(valid_paths, np) then
        table.insert(valid_paths, np)
      end
    end

    if #valid_paths > 0 then
      table.sort(valid_paths, function(a, b) return #a > #b end)
      table.insert(results, { spec = spec, paths = valid_paths })
      if not opts.all then
        break
      end
    end
  end
  return results
end

M.cache = {}

function M.setup()
  local group = vim.api.nvim_create_augroup('SimpleRootCache', { clear = true })

  vim.api.nvim_create_user_command(
    'RootInfo',
    function() M.info() end,
    { desc = 'Neovim roots for the current buffer' }
  )

  vim.api.nvim_create_autocmd({ 'LspAttach', 'BufWritePost', 'DirChanged' }, {
    group = group,
    callback = function(ev) M.cache[ev.buf] = nil end,
  })
end

--- @param opts? { buf?: number }
--- @return string
function M.get(opts)
  local buf = (opts and opts.buf) or vim.api.nvim_get_current_buf()
  if M.cache[buf] then
    return M.cache[buf]
  end

  local roots = M.detect({ all = false, buf = buf })
  local root = roots[1] and roots[1].paths[1] or M.norm(vim.uv.cwd())
  M.cache[buf] = root
  return root
end

function M.info()
  local roots = M.detect({ all = true })
  local lines = { '# Root Detection Info', '' }
  for i, root in ipairs(roots) do
    for _, path in ipairs(root.paths) do
      local icon = i == 1 and '󰄬 ' or '  '
      local spec_str = type(root.spec) == 'table' and table.concat(root.spec, ', ') or tostring(root.spec)
      table.insert(lines, string.format('%s **Path:** `%s` (via `%s`)', icon, path, spec_str))
    end
  end
  if #roots == 0 then
    table.insert(lines, 'No root detected, fallback to CWD: `' .. M.norm(vim.uv.cwd()) .. '`')
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'Root' })
end

return M
