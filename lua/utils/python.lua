local M = {}

local root_util = require('utils.root')

local python_lsp_clients = {
  basedpyright = true,
  pylsp = true,
  pyright = true,
}

local pending_start = {}

local pyright_settings = {
  python = {
    analysis = {
      autoSearchPaths = true,
      diagnosticMode = 'workspace',
      diagnosticSeverityOverrides = {
        reportDuplicateImport = 'none',
        reportUnusedImport = 'none',
        reportUnusedVariable = 'none',
      },
      typeCheckingMode = 'strict',
      useLibraryCodeForTypes = true,
    },
  },
}

local function join(root, name) return root .. '/' .. name end

local function file_exists(root, name) return vim.fn.filereadable(join(root, name)) == 1 end

local function read_file(root, name)
  if not file_exists(root, name) then
    return nil
  end

  local ok, lines = pcall(vim.fn.readfile, join(root, name))
  if not ok then
    return nil
  end

  return table.concat(lines, '\n')
end

local function has_section(content, section)
  if not content then
    return false
  end

  local escaped = section:gsub('([%%%-%^%$%(%)%.%[%]%*%+%?])', '%%%1')
  return content:match('%[%s*' .. escaped .. '%s*%]') ~= nil
end

local function has_any(tools)
  for _, enabled in pairs(tools) do
    if enabled then
      return true
    end
  end

  return false
end

local function executable(name) return vim.fn.exepath(name) ~= '' end

local function is_python_buffer(bufnr) return vim.bo[bufnr].filetype == 'python' end

--- @param bufnr number
--- @return table
function M.detect(bufnr)
  local root = root_util.get({ buf = bufnr }) or vim.uv.cwd()
  root = vim.fs.normalize(root)

  local pyproject = read_file(root, 'pyproject.toml')
  local setup_cfg = read_file(root, 'setup.cfg')
  local tox_ini = read_file(root, 'tox.ini')
  local ruff_toml = read_file(root, 'ruff.toml') or read_file(root, '.ruff.toml')

  local tools = {
    autopep8 = has_section(pyproject, 'tool.autopep8'),
    basedpyright = file_exists(root, 'basedpyrightconfig.json') or has_section(pyproject, 'tool.basedpyright'),
    black = has_section(pyproject, 'tool.black'),
    flake8 = file_exists(root, '.flake8') or has_section(setup_cfg, 'flake8') or has_section(tox_ini, 'flake8'),
    isort = file_exists(root, '.isort.cfg') or has_section(pyproject, 'tool.isort'),
    mypy = file_exists(root, 'mypy.ini')
      or file_exists(root, '.mypy.ini')
      or has_section(pyproject, 'tool.mypy')
      or has_section(setup_cfg, 'mypy'),
    pylint = file_exists(root, '.pylintrc') or file_exists(root, 'pylintrc') or has_section(pyproject, 'tool.pylint'),
    pylsp = file_exists(root, '.pylsp.toml') or file_exists(root, 'pylsp.toml') or has_section(pyproject, 'tool.pylsp'),
    pyright = file_exists(root, 'pyrightconfig.json') or has_section(pyproject, 'tool.pyright'),
    ruff = file_exists(root, '.ruff.toml') or file_exists(root, 'ruff.toml') or has_section(pyproject, 'tool.ruff'),
    ruff_format = has_section(pyproject, 'tool.ruff.format') or has_section(ruff_toml, 'format'),
    yapf = file_exists(root, '.style.yapf') or has_section(pyproject, 'tool.yapf') or has_section(setup_cfg, 'yapf'),
  }

  return {
    has_project_config = has_any(tools),
    root = root,
    tools = tools,
  }
end

--- @param bufnr number
--- @return string[]
function M.linters(bufnr)
  local state = M.detect(bufnr)
  local tools = state.tools
  local linters = {}

  if not state.has_project_config then
    if executable('ruff') then
      return { 'ruff' }
    end

    return {}
  end

  if tools.flake8 and executable('flake8') then
    table.insert(linters, 'flake8')
  end

  if tools.mypy and executable('mypy') then
    table.insert(linters, 'mypy')
  end

  if tools.pylint and executable('pylint') then
    table.insert(linters, 'pylint')
  end

  if tools.ruff and executable('ruff') then
    table.insert(linters, 'ruff')
  end

  return linters
end

--- @param bufnr number
--- @return string[]
function M.formatters(bufnr)
  local state = M.detect(bufnr)
  local tools = state.tools
  local formatters = {}

  if not state.has_project_config then
    if executable('ruff') then
      return { 'ruff_organize_imports', 'ruff_format' }
    end

    return {}
  end

  if tools.isort and executable('isort') then
    table.insert(formatters, 'isort')
  elseif tools.ruff and executable('ruff') and not tools.black then
    table.insert(formatters, 'ruff_organize_imports')
  end

  if tools.black and executable('black') then
    table.insert(formatters, 'black')
  elseif tools.ruff and executable('ruff') and (tools.ruff_format or not (tools.autopep8 or tools.yapf)) then
    table.insert(formatters, 'ruff_format')
  elseif tools.autopep8 and executable('autopep8') then
    table.insert(formatters, 'autopep8')
  elseif tools.yapf and executable('yapf') then
    table.insert(formatters, 'yapf')
  end

  return formatters
end

--- @param bufnr number
--- @param state? table
--- @return string[]
function M.lsp_servers(bufnr, state)
  state = state or M.detect(bufnr)
  local tools = state.tools

  if not state.has_project_config then
    return { 'pyright' }
  end

  if tools.basedpyright then
    return { 'basedpyright' }
  end

  if tools.pyright then
    return { 'pyright' }
  end

  if tools.pylsp then
    return { 'pylsp' }
  end

  return { 'pyright' }
end

--- @param name string
--- @return string[]?
local function lsp_cmd(name)
  if name == 'basedpyright' then
    if executable('basedpyright-langserver') then
      return { 'basedpyright-langserver', '--stdio' }
    end
    return nil
  end

  if name == 'pylsp' then
    if executable('pylsp') then
      return { 'pylsp' }
    end
    return nil
  end

  if name == 'pyright' then
    if executable('pyright-langserver') then
      return { 'pyright-langserver', '--stdio' }
    end
    return nil
  end

  return nil
end

--- @param name string
--- @return table?
local function lsp_settings(name)
  if name == 'basedpyright' or name == 'pyright' then
    return pyright_settings
  end

  return nil
end

local function has_pyright_lsp(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if client.name == 'basedpyright' or client.name == 'pyright' then
      return true
    end
  end

  return false
end

local function has_import_formatter(bufnr)
  for _, formatter in ipairs(M.formatters(bufnr)) do
    if formatter == 'isort' or formatter == 'ruff_organize_imports' then
      return true
    end
  end

  return false
end

local function start_lsp(bufnr)
  local state = M.detect(bufnr)
  local wanted = M.lsp_servers(bufnr, state)
  local wanted_set = {}

  for _, name in ipairs(wanted) do
    wanted_set[name] = true
  end

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if python_lsp_clients[client.name] and not wanted_set[client.name] then
      vim.lsp.buf_detach_client(bufnr, client.id)
    end
  end

  for _, name in ipairs(wanted) do
    if #vim.lsp.get_clients({ bufnr = bufnr, name = name }) == 0 then
      local cmd = lsp_cmd(name)
      if cmd then
        local key = string.format('%d:%s', bufnr, name)
        if not pending_start[key] then
          pending_start[key] = true

          vim.api.nvim_buf_call(
            bufnr,
            function()
              vim.lsp.start({
                cmd = cmd,
                name = name,
                root_dir = state.root,
                settings = lsp_settings(name),
              })
            end
          )

          vim.defer_fn(function() pending_start[key] = nil end, 1000)
        end
      end
    end
  end
end

local function set_python_linters(bufnr)
  local ok, lint = pcall(require, 'lint')
  if not ok then
    return
  end

  lint.linters_by_ft.python = M.linters(bufnr)
end

--- @param bufnr number
function M.setup_buffer(bufnr)
  if not is_python_buffer(bufnr) then
    return
  end

  set_python_linters(bufnr)
  start_lsp(bufnr)
end

--- @param bufnr number
function M.lint_buffer(bufnr)
  if not is_python_buffer(bufnr) then
    return
  end

  M.setup_buffer(bufnr)

  local ok, lint = pcall(require, 'lint')
  if not ok then
    return
  end

  local linters = M.linters(bufnr)
  if #linters == 0 then
    return
  end

  vim.api.nvim_buf_call(bufnr, function() lint.try_lint(linters) end)
end

--- @param bufnr number
function M.organize_imports(bufnr)
  if not is_python_buffer(bufnr) or has_import_formatter(bufnr) or not has_pyright_lsp(bufnr) then
    return
  end

  local params = {
    context = {
      diagnostics = {},
      only = { 'source.organizeImports' },
    },
    range = {
      ['end'] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
      start = { line = 0, character = 0 },
    },
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
  }

  local results = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 1000)
  if not results then
    return
  end

  for client_id, result in pairs(results) do
    local client = vim.lsp.get_client_by_id(client_id)
    local offset_encoding = client and client.offset_encoding or 'utf-16'

    for _, action in pairs(result.result or {}) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, offset_encoding)
      end

      local command = action.command
      if command then
        if type(command) == 'table' then
          vim.lsp.buf.execute_command(command)
        else
          vim.lsp.buf.execute_command({ command = command, arguments = action.arguments })
        end
      end
    end
  end
end

--- @param bufnr number
function M.before_save(bufnr)
  if not is_python_buffer(bufnr) then
    return
  end

  M.setup_buffer(bufnr)
  M.organize_imports(bufnr)
end

return M
