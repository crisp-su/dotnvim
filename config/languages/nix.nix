{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    nixfmt
  ];

  plugins.lsp.servers.nil_ls = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.nix = [
    "nixfmt"
    "injected"
  ];
}
