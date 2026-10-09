{ lib', ... }:

{
  plugins.bufferline = {
    enable = true;

    settings = {
      options = {
        diagnostics = "nvim_lsp";

        close_command.__raw = /* lua */ "function(n) Snacks.bufdelete(n) end";
        right_mouse_command.__raw = /* lua */ "function(n) Snacks.bufdelete(n) end";

        always_show_bufferline = false;
        auto_toggle_bufferline = true;
        show_buffer_close_icons = false;
        show_close_icon = false;

        offsets = [
          {
            filetype = "neo-tree";
            text = "Neo-tree";
            text_align = "left";
            highlight = "NeoTreeRootName";
            separator = true;
          }
        ];
      };
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec [ "<S-h>" "[b" ] {
      desc = "Prev Buffer";
      mode = modes.interact;
      remap = true;
    })
    (mkSpec [ "<S-l>" "]b" ] {
      desc = "Next Buffer";
      mode = modes.interact;
      remap = true;
    })

    (mkSpec [ "[b" "<cmd>BufferLineCyclePrev<cr>" ] {
      desc = "Prev Buffer";
      mode = modes.interact;
    })
    (mkSpec [ "]b" "<cmd>BufferLineCycleNext<cr>" ] {
      desc = "Next Buffer";
      mode = modes.interact;
    })
    (mkSpec [ "[B" "<cmd>BufferLineMovePrev<cr>" ] {
      desc = "Move Buffer Prev";
      mode = modes.interact;
    })
    (mkSpec [ "]B" "<cmd>BufferLineMoveNext<cr>" ] {
      desc = "Move Buffer Next";
      mode = modes.interact;
    })

    (mkSpec [ "<leader>bp" "<cmd>BufferLineTogglePin<cr>" ] {
      desc = "Toggle Pin";
      mode = modes.interact;
    })
    (mkSpec [ "<leader>bP" "<cmd>BufferLineGroupClose ungrouped<cr>" ] {
      desc = "Delete Non-Pinned Buffers";
      mode = modes.interact;
    })
    (mkSpec [ "<leader>bh" "<cmd>BufferLineCloseLeft<cr>" ] {
      desc = "Delete Buffers to the Left";
      mode = modes.interact;
    })
    (mkSpec [ "<leader>bl" "<cmd>BufferLineCloseRight<cr>" ] {
      desc = "Delete Buffers to the Right";
      mode = modes.interact;
    })
  ];

  colorschemes.catppuccin.settings.integrations.bufferline = true;
  plugins.bufferline.settings.highlights.__raw = /* lua */ ''
    (function()
      if (vim.g.colors_name or '''):find('catppuccin') then
        return require('catppuccin.special.bufferline').get_theme()
      else
        return nil
      end
    end)()
  '';
}
