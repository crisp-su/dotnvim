{ lib, lib', ... }:

{
  plugins.scope = {
    enable = true;
    autoLoad = true;

    settings = {
      hooks = {
        post_tab_enter = lib.nixvim.mkRaw /* lua */ "function() vim.cmd.redrawtabline() end";
        post_tab_close = lib.nixvim.mkRaw /* lua */ "function() vim.cmd.redrawtabline() end";
      };
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec [ "<leader><tab>m" "<cmd>ScopeMoveBuf<cr>" ] {
      desc = "Move Buffer to Tab";
      mode = modes.interact;
    })
  ];
}
