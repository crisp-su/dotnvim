{ pkgs, ... }:

{
  dependencies.go = {
    enable = true;
    packageFallback = true;
  };

  extraPackagesAfter = with pkgs; [
    golangci-lint
    gotools
    gofumpt
    govulncheck
  ];

  plugins.lsp.servers.gopls = {
    enable = true;
    packageFallback = true;
  };

  plugins.lsp.servers.golangci_lint_ls = {
    enable = true;
    packageFallback = true;

    rootMarkers = [ "go.mod" ];
  };

  plugins.conform-nvim.settings.formatters_by_ft.go = [
    "goimports"
    "gofumpt"
    "golangci-lint"
  ];
}
