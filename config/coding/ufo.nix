{ lib, ... }:

{
  plugins.nvim-ufo = {
    enable = true;

    lazyLoad.settings.event = [
      "BufReadPost"
      "BufNewFile"
    ];

    settings = {
      fold_virt_text_handler = lib.nixvim.mkRaw /* lua */ "require('d.ufo_fold_virt_text_handler')";
    };
  };

  colorschemes.catppuccin.settings.integrations.ufo = true;
}
