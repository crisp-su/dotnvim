{ lib, ... }:

{
  plugins.alpha = {
    enable = true;

    settings = lib.nixvim.mkRaw /* lua */ "require('d.alpha_dashboard').config";
  };

  colorschemes.catppuccin.settings.integrations.alpha = true;
}
