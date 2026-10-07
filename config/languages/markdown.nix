{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    mdformat
  ];

  plugins.lsp.servers.markdown_oxide = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.markdown = [
    "mdformat"
    "injected"
  ];
}
