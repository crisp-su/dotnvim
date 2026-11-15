{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    terraform
  ];

  plugins.lsp.servers.terraformls = {
    enable = true;
    packageFallback = true;
  };

  plugins.lsp.servers.tflint = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.terraform = [ "terraform_fmt" ];

  filetype = {
    pattern = {
      ".*%.tf" = "terraform";
    };
  };
}
