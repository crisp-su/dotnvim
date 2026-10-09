{ lib, lib', ... }:

{
  plugins.marks = {
    enable = true;

    settings = {
      default_mappings = false;

      sign_priority = {
        builtin = 5;
        lower = 8;
        upper = 15;
        bookmark = 20;
      };

      builtin_marks = [
        "."
        "<"
        ">"
        "^"
      ];
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec
      [
        "m"
        (lib.nixvim.mkRaw /* lua */ "require('d.mark_operator')")
      ]
      {
        desc = "Mark...";
        icon = {
          icon = lib'.icons.common.Bookmarks.fill;
          color = "orange";
        };
        mode = modes.operator;
      }
    )

    (mkSpec
      [
        "<A-]>"
        (lib.nixvim.mkRaw /* lua */ "require('marks').next")
      ]
      {
        desc = "Move to Next Mark";
        mode = modes.full;
      }
    )
    (mkSpec
      [
        "<A-[>"
        (lib.nixvim.mkRaw /* lua */ "require('marks').prev")
      ]
      {
        desc = "Move to Previous Mark";
        mode = modes.full;
      }
    )

    (mkSpec
      [
        "m,"
        (lib.nixvim.mkRaw /* lua */ "require('marks').set_next")
      ]
      {
        desc = "Set Available Mark";
        icon = {
          icon = lib'.icons.common.BookmarkPlus.fill;
          color = "orange";
        };
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "m;"
        (lib.nixvim.mkRaw /* lua */ "require('marks').toggle")
      ]
      {
        desc = "Toggle Line Mark";
        icon = {
          icon = lib'.icons.common.BookmarkMinus.fill;
          color = "orange";
        };
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "m:"
        (lib.nixvim.mkRaw /* lua */ "require('marks').preview")
      ]
      {
        desc = "Preview Mark";
        icon = {
          icon = lib'.icons.common.Bookmark.fill;
          color = "orange";
        };
        mode = modes.interact;
      }
    )
  ];

  autoCmd = [
    {
      group = "HighlightSet";
      desc = "Clear the MarkSignNumHL highlight group to disable highlighting marked line numbers";
      event = "VimEnter";
      callback = lib.nixvim.mkRaw /* lua */ "function() vim.api.nvim_set_hl(0, 'MarkSignNumHL', {}) end";
    }
  ];

  extraConfigLua = /* lua */ ''
    local hl = vim.api.nvim_get_hl(0, { name = 'Character' })
    hl.italic = true
    vim.api.nvim_set_hl(0, 'MarkSignHL', hl)
  '';
}
