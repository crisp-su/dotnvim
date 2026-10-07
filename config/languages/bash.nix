{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    bash
    shellcheck
    shfmt
  ];

  plugins.lsp.servers.bashls = {
    enable = true;
    packageFallback = true;

    settings = {
      bashIde = {
        # Keep diagnostics single-source (nvim-lint)
        shellcheckPath = "";
      };
    };
  };

  plugins.lint.lintersByFt = {
    bash = [
      "bash"
      "shellcheck"
    ];
    sh = [ "shellcheck" ];
  };

  plugins.conform-nvim.settings.formatters_by_ft = {
    bash = [ "shfmt" ];
    sh = [ "shfmt" ];
  };
}
