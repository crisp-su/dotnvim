local function get_width(text) return text and vim.api.nvim_strwidth(text) or 0 end

local function render(bufnr, notif, highlights, config)
  local api = vim.api
  local base = require('notify.render.base')
  local util = require('notify.util')
  local namespace = base.namespace()

  local icon = (notif.icon == '') and '' or (notif.icon .. ' ')
  local icon_sep = ' '

  local title_main = notif.title[1]
  local title_sub = notif.title[2]

  if notif.duplicates and #notif.duplicates > 0 then
    title_main = string.format('%s (x%d)', title_main, #notif.duplicates)
  end

  local padded_message = {}
  for _, line in ipairs(notif.message) do
    table.insert(padded_message, string.format(' %s ', line))
  end

  local icon_w = get_width(icon)
  local icon_sep_w = (icon ~= '') and get_width(icon_sep) or 0
  local title_main_w = get_width(title_main)
  local title_sub_w = get_width(title_sub)
  local title_content_w = 1 + icon_w + icon_sep_w + title_main_w + title_sub_w

  local message_max_w = util.max_line_width(padded_message)
  local padding_count = math.max(0, message_max_w - title_content_w)
  local title_padding = string.rep(' ', padding_count)

  local border_len = math.max(message_max_w, config.minimum_width())
  local border_line = string.rep('·', border_len)

  api.nvim_buf_set_lines(bufnr, 0, 1, false, { '', '' })
  api.nvim_buf_set_lines(bufnr, 2, -1, false, padded_message)

  local header_left = { { ' ' } }
  if icon ~= '' then
    table.insert(header_left, { icon, highlights.icon })
    table.insert(header_left, { icon_sep, highlights.border })
  end
  table.insert(header_left, { title_main .. title_padding, highlights.title })

  api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
    virt_text = header_left,
    virt_text_win_col = 0,
    priority = 10,
  })

  api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
    virt_text = { { title_sub, highlights.title }, { ' ' } },
    virt_text_pos = 'right_align',
    priority = 10,
  })

  api.nvim_buf_set_extmark(bufnr, namespace, 1, 0, {
    virt_text = { { border_line, highlights.border } },
    virt_text_win_col = 0,
    priority = 10,
  })

  api.nvim_buf_set_extmark(bufnr, namespace, 2, 0, {
    hl_group = highlights.body,
    end_line = 1 + #padded_message,
    end_col = get_width(padded_message[#padded_message]),
    priority = 50,
  })
end

return render
