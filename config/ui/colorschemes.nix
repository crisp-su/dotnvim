{ lib, ... }:

{
  colorschemes = {
    catppuccin = {
      enable = true;

      settings = {
        flavour = "auto";
        background = {
          light = "latte";
          dark = "mocha";
        };
        transparent_background = true;
        float.transparent = true;

        lsp_styles = {
          underlines = {
            errors = [ "undercurl" ];
            hints = [ "undercurl" ];
            warnings = [ "undercurl" ];
            information = [ "undercurl" ];
          };
        };

        highlight_overrides = {
          all = lib.nixvim.mkRaw /* lua */ ''
            function(colors)
              return {
                TelescopeSelection = { fg = colors.pink },
                TelescopeSelectionCaret = { fg = colors.pink },
                TelescopeMatching = { fg = colors.red, style = { "bold" } },
              }
            end
          '';
        };
      };
    };
  };

  highlightOverride = {
    CursorLineFold = {
      link = "CursorLineNr";
    };
  };
}
