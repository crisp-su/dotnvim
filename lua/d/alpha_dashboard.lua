--- @class Theme
--- @field config table
--- @field define? table

--- @alias KeymapLhs string
--- @alias KeymapRhs string | function

local utils = {
  wk = require('utils.which-key'),
  strings = require('utils.strings'),
}

--- @param rhs KeymapRhs
--- @return KeymapRhs
local function get_final_keymap_rhs(rhs)
  return utils.wk.get_rhs_by_lhs(rhs --[[@as string]]) or rhs
end

local elements = {
  --- @param style 'Neovim Shadow' | 'Neovim Sharp' | 'Pacman' | 'My Neighbor Totoro'
  --- @return table
  Banner = function(style)
    local ascii_map = {
      ['Neovim Shadow'] = {
        value = {
          [=[                                                    ]=],
          [=[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]=],
          [=[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]=],
          [=[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]=],
          [=[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]=],
          [=[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]=],
          [=[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]=],
          [=[                                                    ]=],
        },
        hl = '@function',
      },
      ['Neovim Sharp'] = {
        value = {
          [=[                                                                       ]=],
          [=[                                                                     ]=],
          [=[       ████ ██████           █████      ██                     ]=],
          [=[      ███████████             █████                             ]=],
          [=[      █████████ ███████████████████ ███   ███████████   ]=],
          [=[     █████████  ███    █████████████ █████ ██████████████   ]=],
          [=[    █████████ ██████████ █████████ █████ █████ ████ █████   ]=],
          [=[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]=],
          [=[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]=],
          [=[                                                                       ]=],
        },
        hl = '@function',
      },
      ['Pacman Map'] = {
        value = {
          [=[ ================================================. ]=],
          [=[      .-.   .-.     .--.                         | ]=],
          [=[     | OO| | OO|   / _.-' .-.   .-.  .-.   .''.  | ]=],
          [=[     |   | |   |   \  '-. '-'   '-'  '-'   '..'  | ]=],
          [=[     '^^^' '^^^'    '--'                         | ]=],
          [=[ ===============.  .-.  .================.  .-.  | ]=],
          [=[                | |   | |                |  '-'  | ]=],
          [=[                | |   | |                |       | ]=],
          [=[                | ':-:' |                |  .-.  | ]=],
          [=[ l42            |  '-'  |                |  '-'  | ]=],
          [=[ ==============='       '================'       | ]=],
        },
        hl = '@constructor',
      },
      ['My Neighbor Totoro'] = {
        value = {
          [=[  _____                                           ,.  ,.      ]=],
          [=[ /     \                                          ||  ||      ]=],
          [=[ vvvvvvv  /|__/|                                 ,''--''.     ]=],
          [=[    I   /O,O   |                                : (.)(.) :    ]=],
          [=[    I /_____   |      /|/|                     ,'        `.   ]=],
          [=[   J|/^ ^ ^ \  |    /00  |    _//|             :          :   ]=],
          [=[    |^ ^ ^ ^ |W|   |/^^\ |   /oo |             :          :   ]=],
          [=[     \m___m__|_|    \m_m_|   \mm_|... .        `._m____m_,'   ]=],
        },
        hl = '@define',
      },
    }

    local ascii = ascii_map[style]

    return {
      type = 'text',

      val = ascii.value,

      opts = {
        position = 'center',
        hl = ascii.hl,
      },
    }
  end,

  --- @param label string
  --- @param lhs KeymapLhs
  --- @param rhs? KeymapRhs
  --- @param map_opts? table
  --- @return table
  ActionButton = function(label, lhs, rhs, map_opts)
    map_opts = map_opts or {}
    map_opts = vim.tbl_extend('force', {
      noremap = true,
      silent = true,
      nowait = true,
    }, map_opts)

    local opts = {
      position = 'center',
      width = 64,
      cursor = 3,

      shortcut = lhs,
      align_shortcut = 'right',
    }

    local on_press = nil

    local icon_end_byte = label:find('%s') or 0

    if rhs then
      rhs = get_final_keymap_rhs(rhs)

      local function execute_action()
        if type(rhs) == 'function' then
          rhs()
        elseif type(rhs) == 'string' then
          local cmd = rhs:match('^<cmd>(.*)<cr>$') or rhs:match('^:(.*)<cr>$')
          if cmd then
            vim.cmd(cmd)
          else
            local keys = vim.api.nvim_replace_termcodes(rhs, true, false, true)
            vim.api.nvim_feedkeys(keys, 'm', true)
          end
        end
      end

      opts.keymap = { 'n', lhs, execute_action, map_opts }
      on_press = execute_action
    end

    opts.hl = {
      { '@keyword', 0, icon_end_byte },
      { '@function', icon_end_byte, #label },
    }
    opts.hl_shortcut = '@character'

    return {
      type = 'button',
      val = label,
      opts = opts,
      on_press = on_press,
    }
  end,

  --- @return table
  HrTitle = function()
    return {
      type = 'text',

      val = function()
        local nvim_version = vim.version()
        local nvim_version_str = string.format('%d.%d', nvim_version.major, nvim_version.minor)

        local str = '[ '
          .. utils.strings.pad_center_text_line(string.format('NEOVIM v%s', nvim_version_str), '=', 64, 2)
          .. ' ]'
        return str
      end,

      opts = {
        position = 'center',
        hl = 'FloatBorder',
      },
    }
  end,

  --- @return table
  Hr = function()
    return {
      type = 'text',

      val = function()
        local str = '[ ' .. utils.strings.pad_center_text_line('', '=', 64, 0) .. ' ]'
        return str
      end,

      opts = {
        position = 'center',
        hl = 'FloatBorder',
      },
    }
  end,

  --- @param percent number
  --- @return number
  DynPaddingTop = function(percent)
    return vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * percent) })
  end,
}

local header = {
  type = 'group',

  val = {
    elements.Banner('My Neighbor Totoro'),
    elements.HrTitle(),
  },

  opts = {
    spacing = 1,
  },
}

local actions = {
  type = 'group',

  val = {
    elements.ActionButton('󰈔  New File', 'n', '<leader>fn'),
    elements.ActionButton('󰙅  NeoTree', 'e', '<leader>fe'),
    elements.ActionButton('󰙅  Oil', '-', '<leader>fo'),
    elements.ActionButton('󱡠  Find Files', 'f', '<leader>ff'),
    elements.ActionButton('󱡠  Live Grep', '/', '<leader>fg'),
    elements.ActionButton('󰊢  Neogit', 'g', '<leader>gg'),
    elements.ActionButton('󰆓  Last Session', 's', '<leader>qs'),
    elements.ActionButton('󰈆  Quit', 'q', '<leader>qq'),
  },

  opts = {
    spacing = 1,
  },
}

local footer = {
  type = 'group',

  val = {
    elements.Hr(),
  },

  opts = {
    spacing = 0,
  },
}

local section = {
  header = header,
  actions = actions,
  footer = footer,
}

local padding_top = elements.DynPaddingTop(0.18)

local config = {
  layout = {
    { type = 'padding', val = padding_top },
    section.header,
    { type = 'padding', val = 2 },
    section.actions,
    { type = 'padding', val = 2 },
    section.footer,
  },

  opts = {
    margin = 5,
  },
}

--- @type Theme
local theme = {
  config = config,
}

return theme
