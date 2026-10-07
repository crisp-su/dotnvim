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

  extraConfigLua = /* lua */ ''
    local ok, lint = pcall(require, 'lint')

    if ok then
      local yamllint = lint.linters.yamllint

      if yamllint then
        yamllint.args = {
          '-f',
          'parsable',
          '-d',
          '{extends: default, rules: {document-start: disable, line-length: disable}}',
          '-',
        }
      end
    end
  '';

  plugins.conform-nvim.settings.formatters_by_ft.yaml = [ "prettierd" ];

  plugins.schemastore.yaml = {
    enable = true;
  };
}
