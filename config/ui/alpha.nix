{
  plugins.alpha = {
    enable = true;

    settings.__raw = /* lua */ "require('d.alpha_dashboard').config";
  };

  colorschemes.catppuccin.settings.integrations.alpha = true;
}
