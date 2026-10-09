{ lib, lib', ... }:

{
  plugins.neo-tree = {
    enable = true;

    settings = {
      popup_border_style = "rounded";

      sources = [
        "filesystem"
        "buffers"
        "git_status"
      ];

      close_if_last_window = true;
      clipboard.sync = "global";

      window = {
        mappings = {
          "<space>" = "none";
          l = "open";
          h = "close_node";
          "." = "toggle_hidden";
        };
      };

      default_component_configs = {
        indent.with_expanders = true;

        icon = with lib'.icons; {
          folder_closed = common.Folder.fill;
          folder_open = common.FolderOpen.fill;
          folder_empty = common.FolderHidden.line;
        };

        git_status.symbols = with lib'.icons.git; {
          added = FileAdded.line;
          modified = FileModified.line;
          renamed = FileRenamed.line;
          deleted = FileDeleted.line;
          ignored = FileIgnored.line;
          staged = FileStaged.line;
          unstaged = FileUnstaged.line;
          untracked = FileUntracked.line;
          conflict = FileConflict.line;
        };
      };

      filesystem = {
        hijack_netrw_behavior = "disabled";
        follow_current_file.enabled = true;
        use_libuv_file_watcher = true;
      };
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec
      [
        "<leader>fe"
        (lib.nixvim.mkRaw
          /* lua */ "function() require('neo-tree.command').execute({ toggle = true, dir = Utils.root() }) end"
        )
      ]
      {
        desc = "Explorer NeoTree (Root Dir)";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<leader>fE"
        (lib.nixvim.mkRaw
          /* lua */ "function() require('neo-tree.command').execute({ toggle = true, dir = vim.uv.cwd() }) end"
        )
      ]
      {
        desc = "Explorer NeoTree (cwd)";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<leader>be"
        (lib.nixvim.mkRaw
          /* lua */ "function() require('neo-tree.command').execute({ source = 'buffers', toggle = true }) end"
        )
      ]
      {
        desc = "Buffer Explorer";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<leader>ge"
        (lib.nixvim.mkRaw
          /* lua */ "function() require('neo-tree.command').execute({ source = 'git_status', toggle = true }) end"
        )
      ]
      {
        desc = "Git Explorer";
        mode = modes.interact;
      }
    )

    (mkSpec [ "<leader>e" "<leader>fe" ] {
      desc = "Explorer NeoTree (Root Dir)";
      mode = modes.interact;
      remap = true;
    })
    (mkSpec [ "<leader>E" "<leader>fE" ] {
      desc = "Explorer NeoTree (cwd)";
      mode = modes.interact;
      remap = true;
    })
  ];

  autoCmd = [
    {
      group = "HackFix";
      desc = "Refresh Git status in Neo-tree when switching tabs";
      event = "TabEnter";
      callback = lib.nixvim.mkRaw /* lua */ "function() require('neo-tree.events').fire_event('git_event') end";
    }
  ];

  colorschemes.catppuccin.settings.integrations.neo-tree = true;
}
