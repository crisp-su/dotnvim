{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    templ
  ];

  plugins.lsp.servers.templ = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.templ = [ "templ" ];
}
