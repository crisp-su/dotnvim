{
  plugins.tiny-inline-diagnostic = {
    enable = true;

    lazyLoad.settings.event = [
      "LspAttach"
    ];

    settings = {
      preset = "ghost";

      options = {
        throttle = 80;

        show_all_diags_on_cursorline = false;
        show_diags_only_under_cursor = false;

        show_source = {
          enabled = true;
          if_many = false;
        };

        show_code = true;

        experimental = {
          # use_window_local_extmarks = true;
        };
      };
    };
  };
}
