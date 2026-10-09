{ pkgs, lib, ... }:

{
  extraPackagesAfter = with pkgs; [
    oxfmt
    deno
    eslint_d
    prettierd
  ];

  plugins.lsp.servers.jsonls = {
    enable = true;
    packageFallback = true;
  };

  plugins.lsp.servers.eslint = {
    enable = true;
    packageFallback = true;

    filetypes = lib.mkAfter [
      "json"
    ];
  };

  plugins.conform-nvim.settings.formatters_by_ft.json.__raw =
    /* lua */ "function() return Utils.formatter.pick({ 'oxfmt', 'deno_fmt', 'eslint_d', 'prettierd' }) end";

  plugins.schemastore.json = {
    enable = true;
  };
}
