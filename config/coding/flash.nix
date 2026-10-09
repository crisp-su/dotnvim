{ lib, lib', ... }:

{
  plugins.flash = {
    enable = true;

    settings = {
      labels = "asdfghjklqwertyuiopzxcvbnm";

      label = {
        rainbow = {
          enabled = true;
          shade = 9;
        };
      };

      modes = {
        search = {
          enabled = false;
        };

        char = {
          enabled = true;
        };

        treesitter = {
          labels = "asdfghjklqwertyuiopzxcvbnm";
          jump = {
            pos = "start";
            autojump = true;
          };
        };
      };

      prompt = {
        enabled = true;
        prefix = [
          [
            "キタ━━━(゜∀゜)♥━━━!!!!! "
            "FlashPromptIcon"
          ]
        ];
      };
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec
      [
        "s"
        (lib.nixvim.mkRaw /* lua */ "function() require('flash').jump() end")
      ]
      {
        desc = "Flash Jump";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "S"
        (lib.nixvim.mkRaw /* lua */ "function() require('flash').treesitter() end")
      ]
      {
        desc = "Flash Treesitter";
        mode = modes.interact;
      }
    )
  ];

  colorschemes.catppuccin.settings.integrations.flash = true;
}
