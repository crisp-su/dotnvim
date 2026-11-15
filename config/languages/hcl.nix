{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    hclfmt
  ];

  plugins.lsp.servers.atlas = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.hcl = [ "hcl" ];
}
