{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    yamllint
    prettierd
  ];

  plugins.lsp.servers.yamlls = {
    enable = true;
    packageFallback = true;
  };

  plugins.lint.lintersByFt.yaml = [ "yamllint" ];

  plugins.conform-nvim.settings.formatters_by_ft.yaml = [ "prettierd" ];

  plugins.schemastore.yaml = {
    enable = true;
  };

  env = {
    YAMLLINT_CONFIG_FILE = pkgs.writeText ".yamllint.yaml" /* yaml */ ''
      extends: default

      rules:
        document-start: disable
        comments: disable
    '';
  };
}
