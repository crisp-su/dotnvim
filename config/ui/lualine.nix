{
  config,
  lib,
  lib',
  ...
}:

with lib.nixvim.utils;
{
  opts = {
    statusline = " ";
    laststatus = 3;
  };

  plugins.lualine = {
    enable = true;

    settings = {
      extensions = [
        (lib.mkIf config.plugins.neo-tree.enable "neo-tree")
        (lib.mkIf config.plugins.telescope.enable (mkRaw /* lua */ "require('d.lualine_telescope_extension')"))
      ];

      options = {
        refresh_time = 16;

        section_separators = {
          left = "";
          right = "";
        };
        component_separators = {
          left = "";
          right = "";
        };
      };

      sections = {
        lualine_a = [
          (
            listToUnkeyedAttrs [ "mode" ]
            // {
              fmt = lib.nixvim.mkRaw /* lua */ ''
                function(str)
                  local mode_map = {
                    ['NORMAL'] = '(=^・・^=)',
                    ['INSERT'] = 'φ(・∀・＊)',
                    ['VISUAL'] = "┐('～`；)┌",
                    ['V-LINE'] = "┐('～`；)┌",
                    ['V-BLOCK'] = "┐('～`；)┌",
                    ['SELECT'] = "┐('～`；)┌",
                    ['COMMAND'] = '(´ー`)y-~~',
                    ['REPLACE'] = '＼ ￣ヘ￣ ',
                    ['TERMINAL'] = '  <コ:彡  ',
                  }
                  return mode_map[str] or str
                end
              '';

              padding = {
                left = 0;
                right = 0;
              };
              separator = {
                left = "";
                right = " ";
              };
            }
          )
        ];
        lualine_b = [
          (
            listToUnkeyedAttrs [ "branch" ]
            // {
              icon = lib'.icons.git.Branch.line;

              padding = {
                left = 0;
                right = 0;
              };
            }
          )
        ];
        lualine_c = [
          (mkRaw /* lua */ "Utils.lualine.root_dir()")

          (
            listToUnkeyedAttrs [ "diagnostics" ]
            // {
              symbols = with lib'.icons.diagnostic; {
                hint = Hint.fill + " ";
                info = Information.fill + " ";
                warn = Warning.fill + " ";
                error = Error.fill + " ";
              };
            }
          )

          (mkRaw /* lua */ "Utils.lualine.pretty_path()")
        ];

        lualine_x = [
          (
            listToUnkeyedAttrs [
              (mkRaw /* lua */ "function() return string.format('Recording @%s', vim.fn.reg_recording()) end")
            ]
            // {
              cond = lib.nixvim.mkRaw /* lua */ "function() return vim.fn.reg_recording() ~= '' end";

              color = "@text.danger";
            }
          )

          (lib.mkIf config.plugins.noice.enable (
            listToUnkeyedAttrs [
              (mkRaw /* lua */ "function() return require('noice').api.status.command.get() end")
            ]
            // {
              cond =
                lib.nixvim.mkRaw
                  /* lua */ "function() return package.loaded['noice'] and require('noice').api.status.command.has() end";
              color = lib.nixvim.mkRaw /* lua */ "function() return { fg = Snacks.util.color('Statement') } end";
            }
          ))

          (
            listToUnkeyedAttrs [ "diff" ]
            // {
              symbols = with lib'.icons.git; {
                added = LineAdded.fill + " ";
                modified = LineModified.fill + " ";
                removed = LineRemoved.fill + " ";
              };
            }
          )
        ];
        lualine_y = [ "progress" ];
        lualine_z = [
          (
            listToUnkeyedAttrs [ "location" ]
            // {
              fmt = lib.nixvim.mkRaw /* lua */ "function(str) return string.format('[%s]', str) end";

              padding = {
                left = 1;
                right = 0;
              };
              separator = {
                left = "";
                right = "";
              };
            }
          )
        ];
      };
    };
  };

  colorschemes.catppuccin.settings.special.lualine = true;
  plugins.lualine.settings.options.theme = lib.nixvim.mkRaw /* lua */ ''
    (function()
      if (vim.g.colors_name or '''):find('catppuccin') then
        return 'catppuccin'
      else
        return 'auto'
      end
    end)()
  '';
}
