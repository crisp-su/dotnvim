{ lib, ... }:

{
  plugins.blink-cmp = {
    enable = true;

    settings = {
      enabled =
        lib.nixvim.mkRaw
          /* lua */ "function() return not vim.tbl_contains({ 'text' }, vim.bo.filetype) end";

      keymap = {
        preset = "super-tab";

        "<cr>" = [
          "accept"
          "fallback"
        ];
      };

      appearance = {
        nerd_font_variant = "mono";
      };

      completion = {
        trigger = {
          show_on_keyword = true;
          show_on_trigger_character = true;
          show_on_insert_on_trigger_character = true;
          show_on_accept_on_trigger_character = true;
        };

        keyword = {
          range = "full";
        };

        accept = {
          auto_brackets = {
            enabled = false;
          };
        };

        menu = {
          auto_show = true;
          auto_show_delay_ms = 300;

          draw = {
            columns = [
              { __unkeyed-1 = "kind_icon"; }
              {
                __unkeyed-1 = "label";
                gap = 1;
              }
            ];
            components = {
              label = {
                text =
                  lib.nixvim.mkRaw
                    /* lua */ "function(ctx) return require('colorful-menu').blink_components_text(ctx) end";
                highlight =
                  lib.nixvim.mkRaw
                    /* lua */ "function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end";
              };
            };
          };
        };

        list = {
          selection = {
            preselect = true;
            auto_insert = false;
          };
        };

        documentation = {
          auto_show = true;
          auto_show_delay_ms = 0;
        };

        ghost_text = {
          enabled = true;
          show_with_menu = true;
        };
      };

      sources = {
        default = [
          "lsp"
          "snippets"
          "path"
          "buffer"
        ];

        providers = {
          lsp = {
            name = "LSP";
            module = "blink.cmp.sources.lsp";

            async = true;
          };
        };
      };

      cmdline = {
        keymap = {
          preset = "cmdline";

          "<tab>" = [ "accept" ];
        };

        completion = {
          menu = {
            auto_show = lib.nixvim.mkRaw /* lua */ "function(ctx) return vim.fn.getcmdtype() == ':' end";
          };
        };
      };

      fuzzy = {
        implementation = "prefer_rust_with_warning";
        sorts = [
          "exact"
          "score"
          "sort_text"
        ];
      };

      signature = {
        enabled = true;
      };
    };
  };

  plugins.colorful-menu = {
    enable = true;
  };

  colorschemes.catppuccin.settings.integrations.blink_cmp = {
    style = "bordered";
  };
}
