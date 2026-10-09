local function create_layout(picker)
  local NuiLayout = require('nui.layout')
  local NuiPopup = require('nui.popup')

  local ts = require('telescope')
  local ts_pickers = require('telescope.pickers')
  local TSLayout = require('telescope.pickers.layout')

  --- @param title string
  --- @return string
  local function format_title_text(title) return string.format(' %s ', title) end

  local function make_popup(opts)
    local popup = NuiPopup(opts)

    --- @diagnostic disable-next-line: inject-field
    function popup.border:change_title(title) popup.border.set_text(popup.border, 'top', format_title_text(title)) end

    return TSLayout.Window(popup)
  end

  local prompt = make_popup({
    enter = true,
    border = {
      style = 'rounded',
      padding = { 0, 1 },
      text = {
        top = format_title_text(picker.prompt_title),
        top_align = 'center',
      },
    },
  })

  local results = make_popup({
    focusable = false,
    border = {
      style = 'rounded',
      padding = { 0, 0 },
      text = {
        top = format_title_text(picker.results_title),
        top_align = 'center',
      },
    },
  })

  local preview = make_popup({
    focusable = false,
    border = {
      style = 'rounded',
      padding = { 0, 1 },
      text = {
        top = format_title_text(picker.preview_title),
        top_align = 'center',
      },
    },
  })

  local gap = NuiPopup({
    focusable = false,
    border = { style = 'none' },
    win_options = {
      winhighlight = 'Normal:TelescopeNormal',
    },
  })

  local box = NuiLayout.Box({
    NuiLayout.Box({
      NuiLayout.Box(prompt, { size = 3 }),
      NuiLayout.Box(results, { grow = 1 }),
    }, { dir = 'col', size = '40%' }),
    NuiLayout.Box(gap, { size = 1 }),
    NuiLayout.Box(preview, { size = '60%' }),
  }, { dir = 'row' })

  local function get_layout_size()
    return {
      width = vim.o.columns < 120 and '95%' or '80%',
      height = vim.o.lines < 36 and '95%' or '80%',
    }
  end

  local update_layout = NuiLayout.update

  local layout = NuiLayout({
    relative = 'editor',
    position = '50%',
    size = get_layout_size(),
  }, box)

  layout.prompt = prompt
  layout.results = results
  layout.preview = preview

  function layout:update() update_layout(self, { size = get_layout_size() }, box) end

  return TSLayout(layout)
end

return create_layout
