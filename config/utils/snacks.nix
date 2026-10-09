{
  config,
  lib,
  ...
}:

{
  plugins.snacks = {
    enable = true;

    settings = {
      util.enabled = true;
      bufdelete.enabled = true;
      rename.enabled = true;
      picker.enabled = true;
      words.enabled = true;
    };

    luaConfig = lib.mkIf config.plugins.noice.enable {
      pre = /* lua */ "local __vim_notify = vim.notify";
      post = /* lua */ "vim.notify = __vim_notify";
    };
  };

  colorschemes.catppuccin.settings.integrations.snacks = true;
}
