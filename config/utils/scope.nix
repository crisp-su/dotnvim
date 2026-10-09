{ lib', ... }:

{
  plugins.scope = {
    enable = true;
    autoLoad = true;

    settings = {
      hooks = {
        post_tab_enter.__raw = /* lua */ "function() vim.cmd.redrawtabline() end";
        post_tab_close.__raw = /* lua */ "function() vim.cmd.redrawtabline() end";
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
