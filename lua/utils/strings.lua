local M = {}

--- @param str string
--- @param fillchar string
--- @param length number
--- @param spaces number
--- @return string result
--- @return [number, number] range
function M.pad_center_text_line(str, fillchar, length, spaces)
  str = tostring(str or '')
  fillchar = tostring(fillchar or ' ')

  local str_width = vim.api.nvim_strwidth(str)
  local fill_unit_width = vim.api.nvim_strwidth(fillchar)
  local padding_spaces = string.rep(' ', spaces)

  local core = padding_spaces .. str .. padding_spaces
  local core_width = str_width + (spaces * 2)

  if core_width >= length then
    local start_byte = #padding_spaces + 1
    local end_byte = start_byte + #str - 1
    return core, { start_byte, end_byte }
  end

  local total_fill_width = length - core_width
  local left_fill_width = math.floor(total_fill_width / 2)
  local right_fill_width = total_fill_width - left_fill_width

  local function generate_padding(target_w)
    if target_w <= 0 then
      return ''
    end
    if fill_unit_width <= 0 then
      return string.rep(' ', target_w)
    end

    local count = math.floor(target_w / fill_unit_width)
    local s = string.rep(fillchar, count)

    local remainder = target_w % fill_unit_width
    if remainder > 0 then
      s = s .. string.rep(' ', remainder)
    end
    return s
  end

  local left_pad = generate_padding(left_fill_width)
  local right_pad = generate_padding(right_fill_width)

  local start_byte = #left_pad + #padding_spaces + 1
  local end_byte = start_byte + #str - 1

  local result = left_pad .. core .. right_pad
  return result, { start_byte, end_byte }
end

return M
