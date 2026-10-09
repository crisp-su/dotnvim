{
  config,
  lib,
  lib',
  ...
}:

lib.mkIf config.plugins.snacks.enable {
  plugins.snacks.settings.toggle = {
    which_key = lib.mkIf (!config.plugins.which-key.enable) false;

    notify = true;

    icon = with lib'.icons.common; {
      enabled = ToggleOn.fill;
      disabled = ToggleOff.fill;
    };
    color = {
      enabled = "green";
      disabled = "yellow";
    };
    wk_desc = {
      enabled = "Disable ";
      disabled = "Enable ";
    };
  };

  autoCmd = [
    {
      group = "Lazy";
      desc = "Setup quick settings module";
      event = "VimEnter";
      callback = lib.nixvim.mkRaw /* lua */ "function() require('d.quick_settings').setup() end";
    }
  ];
}
