{ lib', ... }:

{
  plugins.neogit = {
    enable = true;

    lazyLoad.settings.cmd = [
      "Neogit"
    ];

    settings = {
      disable_signs = true;

      signs = {
        section = [
          "#"
          "&"
        ];
        item = [
          "+"
          "-"
        ];
        hunk = [
          "\""
          "'"
        ];
      };

      mappings = {
        status = {
          "<space>" = "Toggle";
        };
      };
    };
  };

  plugins.which-key.settings.spec =
    with lib'.utils.wk;
    with lib'.icons;
    [
      (mkSpec
        [
          "<leader>gg"
          {
            __raw = /* lua */ "function() vim.cmd.Neogit({ 'cwd=' .. vim.fn.fnameescape(Utils.root()) }) end";
          }
        ]
        {
          desc = "Neogit";
          mode = modes.interact;
          icon = {
            icon = common.Neogit.line;
            color = "orange";
          };
        }
      )
    ];

  highlightOverride = {
    NeogitFloatBorder = {
      link = "WinSeparator";
    };
  };

  colorschemes.catppuccin.settings.integrations.neogit = true;
}
