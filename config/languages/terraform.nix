{ pkgs, lib, ... }:

{
  extraPackagesAfter = with pkgs; [
    terraform
    tflint
  ];

  plugins.lsp.servers.terraformls = {
    enable = true;
    packageFallback = true;
  };

  plugins.lint.lintersByFt.terraform = [ ];

  plugins.conform-nvim.settings.formatters_by_ft.terraform = [ "terraform_fmt" ];

  filetype = {
    pattern = {
      ".*%.tf" = "terraform";
    };
  };

  autoCmd = [
    {
      group = "Auto";
      event = "FileType";
      pattern = "terraform";
      callback =
        lib.nixvim.mkRaw
          /* lua */ "function(args) Utils.linter.set_external_linters(vim.bo[args.buf].filetype, { 'tflint' }) end";
    }
  ];
}
