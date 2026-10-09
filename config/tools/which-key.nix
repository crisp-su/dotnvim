{ lib', ... }:

{
  plugins.which-key = {
    enable = true;

    settings = {
      preset = "helix";

      triggers = with lib'.utils.wk; [
        {
          __unkeyed-1 = "<auto>";
          mode = modes.all;
        }

        {
          __unkeyed-1 = "m";
          mode = modes.all;
        }
      ];

      icons = with lib'.icons; {
        rules = [
          {
            pattern = "terminal";
            icon = common.Terminal.fill;
            color = "red";
          }
          {
            pattern = "window";
            icon = common.Window.fill;
            color = "blue";
          }
          {
            pattern = "tab";
            icon = common.Tab.line;
            color = "purple";
          }
          {
            pattern = "buffer";
            icon = common.Buffer.line;
            color = "cyan";
          }
          {
            pattern = "file";
            icon = common.File.fill;
            color = "cyan";
          }
          {
            pattern = "code";
            icon = common.Code.line;
            color = "orange";
          }
          {
            pattern = "diagnostic";
            icon = common.Diagnostic.line;
            color = "green";
          }
          {
            pattern = "format";
            icon = common.Format.line;
            color = "cyan";
          }
          {
            pattern = "debug";
            icon = common.Debug.fill;
            color = "red";
          }
          {
            pattern = "explore";
            icon = common.Tree.fill;
            color = "yellow";
          }
          {
            pattern = "git";
            icon = common.Git.fill;
            color = "orange";
          }
          {
            pattern = "ai";
            icon = common.AI.fill;
            color = "purple";
          }
          {
            pattern = "notif";
            icon = common.Notification.fill;
            color = "blue";
          }
          {
            pattern = "toggle";
            icon = common.ToggleOff.fill;
            color = "yellow";
          }
          {
            pattern = "session";
            icon = common.Save.fill;
            color = "azure";
          }
          {
            pattern = "exit";
            icon = common.Exit.line;
            color = "red";
          }
          {
            pattern = "quit";
            icon = common.Exit.line;
            color = "red";
          }
        ];
      };

      spec = with lib'.utils.wk; [
      ];
    };

    luaConfig = {
      pre = /* lua */ "Utils.wk.setup_pre()";
      post = /* lua */ "Utils.wk.setup_post()";
    };
  };

  colorschemes.catppuccin.settings.integrations.which_key = true;
}
