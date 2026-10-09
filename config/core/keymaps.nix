{
  config,
  settings,
  lib,
  lib',
  ...
}:

{
  globals.mapleader = settings.core.keymaps.leader;

  plugins.which-key.settings.spec =
    with lib'.utils.wk;
    with lib'.icons;
    let
      inherit (lib) mkIf;
    in
    lib.mkBefore [
      (mkSpec [ "<leader>w" ] {
        group = "windows";
        mode = modes.all;
      })
      (mkSpec [ "<leader>b" ] {
        group = "buffer";
        mode = modes.all;
      })
      (mkSpec [ "<leader>s" ] {
        group = "search";
        mode = modes.all;
      })
      (mkSpec [ "<leader>f" ] {
        group = "find/file";
        mode = modes.all;
      })
      (mkSpec [ "<leader>c" ] {
        group = "code";
        mode = modes.all;
      })
      (mkSpec [ "<leader>d" ] {
        group = "debug";
        mode = modes.all;
      })
      (mkSpec [ "<leader>t" ] {
        group = "test";
        mode = modes.all;
      })
      (mkSpec [ "<leader>x" ] {
        group = "diagnostics/quickfix";
        mode = modes.all;
      })
      (mkSpec [ "<leader>g" ] {
        group = "git";
        mode = modes.all;
      })
      (mkSpec [ "<leader><tab>" ] {
        group = "tabs";
        mode = modes.all;
      })
      (mkSpec [ "<leader>;" ] {
        group = "settings";
        mode = modes.all;
        icon = {
          icon = common.Setting.fill;
          color = "yellow";
        };
      })
      (mkSpec [ "<leader>q" ] {
        group = "quit/session";
        mode = modes.all;
      })

      # --------------------

      (mkSpec
        [
          "<esc>"
          {
            __raw = /* lua */ ''
              function()
                vim.cmd.noh()
                return '<esc>'
              end
            '';
          }
        ]
        {
          desc = "Escape and Clear hlsearch";
          mode = modes.view;
          expr = true;
        }
      )

      (mkIf config.plugins.noice.enable (
        mkSpec
          [
            "<C-f>"
            {
              __raw = /* lua */ ''
                function()
                  if not require('noice.lsp').scroll(4) then
                    return '<c-f>'
                  end
                end
              '';
            }
          ]
          {
            desc = "Scroll Forward";
            mode = modes.view;
            expr = true;
          }
      ))
      (mkIf config.plugins.noice.enable (
        mkSpec
          [
            "<C-b>"
            {
              __raw = /* lua */ ''
                function()
                  if not require('noice.lsp').scroll(-4) then
                    return '<c-b>'
                  end
                end
              '';
            }
          ]
          {
            desc = "Scroll Backward";
            mode = modes.full;
            expr = true;
          }
      ))

      (mkSpec [ "j" "v:count == 0 ? 'gj' : 'j'" ] {
        desc = "Down";
        mode = modes.interact;
        expr = true;
        silent = true;
      })
      (mkSpec [ "k" "v:count == 0 ? 'gk' : 'k'" ] {
        desc = "Up";
        mode = modes.interact;
        expr = true;
        silent = true;
      })

      (mkSpec [ "<C-h>" "<C-w>h" ] {
        desc = "Go to Left Window";
        mode = modes.common;
        remap = true;
      })
      (mkSpec [ "<C-j>" "<C-w>j" ] {
        desc = "Go to Lower Window";
        mode = modes.common;
        remap = true;
      })
      (mkSpec [ "<C-k>" "<C-w>k" ] {
        desc = "Go to Upper Window";
        mode = modes.common;
        remap = true;
      })
      (mkSpec [ "<C-l>" "<C-w>l" ] {
        desc = "Go to Right Window";
        mode = modes.common;
        remap = true;
      })

      (mkSpec [ "<C-Left>" "<cmd>vertical resize -2<cr>" ] {
        desc = "Decrease Window Width";
        mode = modes.interact;
      })
      (mkSpec [ "<C-Right>" "<cmd>vertical resize +2<cr>" ] {
        desc = "Increase Window Width";
        mode = modes.interact;
      })
      (mkSpec [ "<C-Up>" "<cmd>resize +2<cr>" ] {
        desc = "Increase Window Height";
        mode = modes.interact;
      })
      (mkSpec [ "<C-Down>" "<cmd>resize -2<cr>" ] {
        desc = "Decrease Window Height";
        mode = modes.interact;
      })

      (mkSpec [ "<leader>-" "<C-W>s" ] {
        desc = "Split Window Below";
        mode = modes.interact;
        remap = true;
      })
      (mkSpec [ "<leader>|" "<C-W>v" ] {
        desc = "Split Window Right";
        mode = modes.interact;
        remap = true;
      })
      (mkSpec [ "<leader>wd" "<C-W>c" ] {
        desc = "Delete Window";
        mode = modes.interact;
        remap = true;
      })

      (mkSpec [ "[b" "<cmd>bprevious<cr>" ] {
        desc = "Prev Buffer";
        mode = modes.interact;
      })
      (mkSpec [ "]b" "<cmd>bnext<cr>" ] {
        desc = "Next Buffer";
        mode = modes.interact;
      })
      (mkSpec [ "<leader>bb" "<cmd>e #<cr>" ] {
        desc = "Switch to Other Buffer";
        mode = modes.interact;
      })
      (mkIf config.plugins.snacks.enable (
        mkSpec
          [
            "<leader>bd"
            { __raw = /* lua */ "function() Snacks.bufdelete() end"; }
          ]
          {
            desc = "Delete Buffer";
            mode = modes.interact;
          }
      ))
      (mkIf config.plugins.snacks.enable (
        mkSpec
          [
            "<leader>bo"
            { __raw = /* lua */ "function() Snacks.bufdelete.other() end"; }
          ]
          {
            desc = "Delete Other Buffers";
            mode = modes.interact;
          }
      ))
      (mkSpec [ "<leader>bD" "<cmd>bd<cr>" ] {
        desc = "Delete Buffer and Window";
        mode = modes.interact;
      })

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

      (mkSpec [ "<leader><tab>[" "<cmd>tabprevious<cr>" ] {
        desc = "Previous Tab";
        mode = modes.interact;
      })
      (mkSpec [ "<leader><tab>]" "<cmd>tabnext<cr>" ] {
        desc = "Next Tab";
        mode = modes.interact;
      })
      (mkSpec [ "<leader><tab><tab>" "<cmd>tabnew<cr>" ] {
        desc = "New Tab";
        mode = modes.interact;
      })
      (mkSpec [ "<leader><tab>d" "<cmd>tabclose<cr>" ] {
        desc = "Close Tab";
        mode = modes.interact;
      })
      (mkSpec [ "<leader><tab>o" "<cmd>tabonly<cr>" ] {
        desc = "Close Other Tabs";
        mode = modes.interact;
      })

      (mkSpec [ "n" "'Nn'[v:searchforward].'zv'" ] {
        desc = "Next Search Result";
        mode = modes.interact;
        expr = true;
      })
      (mkSpec [ "N" "'nN'[v:searchforward].'zv'" ] {
        desc = "Prev Search Result";
        mode = modes.interact;
        expr = true;
      })

      (mkSpec [ "gco" "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>" ] {
        desc = "Add Comment Below";
        mode = modes.interact;
      })
      (mkSpec [ "gcO" "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>" ] {
        desc = "Add Comment Above";
        mode = modes.interact;
      })

      (mkSpec [ "<A-j>" "<cmd>execute 'move .+' . v:count1<cr>==" ] {
        desc = "Move Down";
        mode = "n";
      })
      (mkSpec [ "<A-k>" "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==" ] {
        desc = "Move Up";
        mode = "n";
      })
      (mkSpec [ "<A-j>" "<esc><cmd>m .+1<cr>==gi" ] {
        desc = "Move Down";
        mode = "i";
      })
      (mkSpec [ "<A-k>" "<esc><cmd>m .-2<cr>==gi" ] {
        desc = "Move Up";
        mode = "i";
      })
      (mkSpec [ "<A-j>" ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv" ] {
        desc = "Move Down";
        mode = "v";
      })
      (mkSpec [ "<A-k>" ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv" ] {
        desc = "Move Up";
        mode = "v";
      })

      (mkSpec [ "<" "<gv" ] {
        desc = "Indent Left";
        mode = "v";
      })
      (mkSpec [ ">" ">gv" ] {
        desc = "Indent Right";
        mode = "v";
      })

      (mkSpec [ "<C-s>" "<cmd>w<cr>" ] {
        desc = "Save File";
        mode = modes.full;
      })

      (mkSpec [ "<leader>fn" "<cmd>enew<cr>" ] {
        desc = "New File";
        mode = modes.interact;
      })

      (mkSpec [ "<leader>qq" "<cmd>qa<cr>" ] {
        desc = "Quit All";
        mode = modes.interact;
      })
      (mkSpec [ "<leader>qQ" "<cmd>qa!<cr>" ] {
        desc = "Quit All (Don't Save)";
        mode = modes.interact;
      })

      # --------------------

      # (mkSpec [ "<C-f>" "<cmd>set filetype?<cr>" ] {
      #   desc = "[VIM DEBUG] GET FILETYPE";
      #   mode = modes.all;
      #   hidden = true;
      # })
      # (mkSpec [ "<C-b>" "<cmd>set buftype?<cr>" ] {
      #   desc = "[VIM DEBUG] GET BUFTYPE";
      #   mode = modes.all;
      #   hidden = true;
      # })
    ];
}
