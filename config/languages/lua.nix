{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    stylua
  ];

  plugins.lsp.servers.lua_ls = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.lua = [ "stylua" ];
}
