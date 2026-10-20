{ pkgs, ... }:

{
  plugins.tiny-inline-diagnostic = {
    enable = true;
    package = pkgs.vimPlugins.tiny-inline-diagnostic-nvim.overrideAttrs {
      patches = [
        # Patch: `setlocal nobuflisted` (scope.nvim on TabLeave) fires BufDelete on
        # live buffers, which made the plugin detach permanently until LspRestart.
        # Defer the detach until the buffer is actually gone.
        ../../patches/tiny-inline-diagnostic-fix-bufdelete.patch
      ];
    };

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
