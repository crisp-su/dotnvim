{ lib', ... }:

{
  plugins.oil = {
    enable = true;

    luaConfig.pre = /* lua */ ''
      Utils.oil.setup()
    '';

    settings = {
      columns = [
        "icon"
      ];

      watch_for_changes = true;
      skip_confirm_for_simple_edits = true;

      lsp_file_methods.autosave_changes = "unmodified";

      float = {
        padding = 2;
        max_width = 0.9;
        max_height = 0.9;
        border = "rounded";
      };

      confirmation.border = "rounded";
      progress.border = "rounded";
      ssh.border = "rounded";
      keymaps_help.border = "rounded";

      win_options = {
        winbar = "%!v:lua.Utils.oil.winbar()";
      };

      view_options = {
        show_hidden = true;
        is_always_hidden.__raw = /* lua */ "Utils.oil.is_always_hidden";
      };

      preview_win = {
        disable_preview.__raw = /* lua */ "Utils.oil.disable_preview";
      };

      use_default_keymaps = false;

      keymaps = {
        "<C-r>" = "actions.refresh";

        L = {
          callback.__raw = /* lua */ "Utils.oil.select";
        };
        "<cr>" = {
          callback.__raw = /* lua */ "Utils.oil.select";
        };
        H = "actions.parent";

        "<M-l>" = {
          __unkeyed-1 = "actions.select";
          opts.vertical = true;
        };

        "<space>" = "actions.preview";

        gd = {
          callback.__raw = /* lua */ "Utils.oil.toggle_details";
          desc = "Toggle detail view";
        };

        "-" = {
          callback.__raw = /* lua */ "Utils.oil.close";
        };
        "<C-w>q" = {
          callback.__raw = /* lua */ "Utils.oil.close";
        };
        "<C-c>" = {
          callback.__raw = /* lua */ "Utils.oil.close";
        };
      };
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec
      [
        "<leader>fo"
        { __raw = /* lua */ "function() Utils.oil.open_root_tab() end"; }
      ]
      {
        desc = "Explorer Oil (Root Dir)";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<leader>fO"
        { __raw = /* lua */ "function() Utils.oil.open_cwd_tab() end"; }
      ]
      {
        desc = "Explorer Oil (cwd)";
        mode = modes.interact;
      }
    )

    (mkSpec
      [
        "-"
        { __raw = /* lua */ "function() Utils.oil.open_parent_tab() end"; }
      ]
      {
        desc = "Explorer Oil (Parent Dir)";
        mode = modes.interact;
      }
    )
  ];
}
