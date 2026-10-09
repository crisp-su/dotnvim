{
  config,
  lib,
  lib',
  ...
}:

{
  dependencies.ripgrep.enable = true;

  plugins.telescope = {
    enable = true;

    extensions = {
      fzf-native.enable = true;
      media-files = {
        enable = true;
        settings = {
          filetypes = [
            "png"
            "jpg"
            "jpeg"
            "webp"
          ];
          find_cmd = "rg";
        };
      };
    };

    settings = {
      defaults = with lib'; {
        sorting_strategy = "ascending";

        prompt_prefix = icons.prompt.Input.line + " ";
        selection_caret = icons.prompt.ListSelection.line + " ";

        create_layout = lib.nixvim.mkRaw /* lua */ "require('d.telescope_layout')";

        mappings = {
          i = {
            "<esc>" = lib.nixvim.mkRaw /* lua */ ''
              function(bufnr)
                require('telescope.actions').close(bufnr)
                vim.schedule(function() vim.cmd.stopinsert() end)
              end
            '';

            "<C-j>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').move_selection_next";
            "<C-k>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').move_selection_previous";
            "<C-d>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').results_scrolling_down";
            "<C-u>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').results_scrolling_up";
            "<C-f>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').preview_scrolling_down";
            "<C-b>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').preview_scrolling_up";
            "<A-n>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').cycle_history_next";
            "<A-p>" = lib.nixvim.mkRaw /* lua */ "require('telescope.actions').cycle_history_prev";

            "<cr>" = lib.nixvim.mkRaw /* lua */ ''
              function(bufnr)
                require('telescope.actions').select_default(bufnr)
                vim.schedule(function() vim.cmd.stopinsert() end)
              end
            '';
          };
          n = { };
        };

        pickers = {
          find_files = {
            find_command = [
              "rg"
              "--files"
              "--color"
              "never"
              "-g"
              "!.git"
            ];
            hidden = true;
          };
        };
      };
    };

    luaConfig.post = lib.mkIf config.plugins.scope.enable /* lua */ ''
      pcall(require('telescope').load_extension, 'scope')
    '';
  };

  plugins.which-key.settings.spec =
    with lib'.utils.wk;
    with lib'.icons;
    let
      inherit (lib) mkIf;

      telescopeIcon = {
        icon = "󱡠";
        color = "azure";
      };
    in
    [
      (mkSpec
        [
          "<leader>ff"
          (lib.nixvim.mkRaw /* lua */ "function() require('telescope.builtin').find_files({ cwd = Utils.root() }) end")
        ]
        {
          desc = "Find Files (Root Dir)";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )
      (mkSpec
        [
          "<leader>fF"
          (lib.nixvim.mkRaw /* lua */ "function() require('telescope.builtin').find_files({ cwd = vim.uv.cwd() }) end")
        ]
        {
          desc = "Find Files (cwd)";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )
      (mkSpec
        [
          "<leader>fg"
          (lib.nixvim.mkRaw /* lua */ "function() require('telescope.builtin').live_grep({ cwd = Utils.root() }) end")
        ]
        {
          desc = "Live Grep (Root Dir)";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )
      (mkSpec
        [
          "<leader>fG"
          (lib.nixvim.mkRaw /* lua */ "function() require('telescope.builtin').live_grep({ cwd = vim.uv.cwd() }) end")
        ]
        {
          desc = "Live Grep (cwd)";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )
      (mkSpec
        [
          "<leader>fb"
          (lib.nixvim.mkRaw
            /* lua */ "function() require('telescope.builtin').buffers({ sort_mru = true, sort_lastused = true }) end"
          )
        ]
        {
          desc = "Buffers";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )
      (mkIf config.plugins.scope.enable (
        mkSpec
          [
            "<leader>fB"
            (lib.nixvim.mkRaw /* lua */ ''
              function()
                local telescope = require('telescope')
                pcall(telescope.load_extension, 'scope')

                if telescope.extensions.scope and telescope.extensions.scope.buffers then
                  telescope.extensions.scope.buffers()
                  return
                end

                require('telescope.builtin').buffers()
              end
            '')
          ]
          {
            desc = "Buffers (All Tabs)";
            icon = telescopeIcon;
            mode = modes.interact;
          }
      ))
      (mkIf (!config.plugins.scope.enable) (
        mkSpec
          [
            "<leader>fB"
            (lib.nixvim.mkRaw /* lua */ "function() require('telescope.builtin').buffers() end")
          ]
          {
            desc = "Buffers (all)";
            icon = telescopeIcon;
            mode = modes.interact;
          }
      ))
      (mkSpec
        [
          "<leader>fh"
          (lib.nixvim.mkRaw /* lua */ "function() require('telescope.builtin').help_tags() end")
        ]
        {
          desc = "Help Tags";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )
      (mkSpec
        [
          "<leader>fP"
          (lib.nixvim.mkRaw /* lua */ "function() require('telescope').extensions.media_files.media_files() end")
        ]
        {
          desc = "Help Tags";
          icon = telescopeIcon;
          mode = modes.interact;
        }
      )

      (mkSpec [ "<leader><space>" "<leader>ff" ] {
        desc = "Find Files (Root Dir)";
        icon = telescopeIcon;
        mode = modes.interact;
        remap = true;
      })
      (mkSpec [ "<leader>/" "<leader>fg" ] {
        desc = "Live Grep (Root Dir)";
        icon = telescopeIcon;
        mode = modes.interact;
        remap = true;
      })
      (mkSpec [ "<leader>," "<leader>fb" ] {
        desc = "Switch Buffer";
        icon = telescopeIcon;
        mode = modes.interact;
        remap = true;
      })
    ];

  colorschemes.catppuccin.settings.integrations.telescope = true;
}
