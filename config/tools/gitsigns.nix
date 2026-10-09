{ lib, lib', ... }:

{
  plugins.gitsigns = {
    enable = true;

    settings = {
      signcolumn = true;
      signs = {
        add = {
          text = "▎";
        };
        change = {
          text = "▎";
        };
        delete = {
          text = "";
        };
        topdelete = {
          text = "";
        };
        changedelete = {
          text = "▎";
        };
        untracked = {
          text = "▎";
        };
      };
      signs_staged = {
        add = {
          text = "▎";
        };
        change = {
          text = "▎";
        };
        delete = {
          text = "";
        };
        topdelete = {
          text = "";
        };
        changedelete = {
          text = "▎";
        };
      };

      current_line_blame = false; # disabled by default
      current_line_blame_opts = {
        virt_text = true;
        use_focus = true;
        delay = 0;
        virt_text_priority = 100;
      };
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec
      [
        "]h"
        (lib.nixvim.mkRaw /* lua */ ''
          function()
            if vim.wo.diff then
              vim.cmd.normal({ ']c', bang = true })
            else
              require('gitsigns').nav_hunk('next')
            end
          end
        '')
      ]
      {
        desc = "Next Hunk";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "[h"
        (lib.nixvim.mkRaw /* lua */ ''
          function()
            if vim.wo.diff then
              vim.cmd.normal({ '[c', bang = true })
            else
              require('gitsigns').nav_hunk('prev')
            end
          end
        '')
      ]
      {
        desc = "Prev Hunk";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "]H"
        (lib.nixvim.mkRaw /* lua */ "function() require('gitsigns').nav_hunk('last') end")
      ]
      {
        desc = "Last Hunk";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "[H"
        (lib.nixvim.mkRaw /* lua */ "function() require('gitsigns').nav_hunk('first') end")
      ]
      {
        desc = "First Hunk";
        mode = modes.interact;
      }
    )

    (mkSpec
      [
        "<space>gd"
        (lib.nixvim.mkRaw /* lua */ "function() require('gitsigns').diffthis() end")
      ]
      {
        desc = "Diff This";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<space>gd"
        (lib.nixvim.mkRaw /* lua */ "function() require('gitsigns').diffthis() end")
      ]
      {
        desc = "Diff This";
        mode = modes.interact;
      }
    )
  ];

  colorschemes.catppuccin.settings.integrations.gitsigns = true;
}
