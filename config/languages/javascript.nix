{ pkgs, lib, ... }:

{
  extraPackagesAfter = with pkgs; [
    oxfmt
    deno
    eslint_d
    prettierd
  ];

  plugins.lsp.servers.ts_ls = {
    enable = true;
    packageFallback = true;
  };

  plugins.lsp.servers.eslint = {
    enable = true;
    packageFallback = true;

    filetypes = lib.mkAfter [
      "javascript"
      "javascriptreact"
      "javascript.jsx"
      "typescript"
      "typescriptreact"
      "typescript.tsx"
    ];
  };

  plugins.lsp.servers.oxlint = {
    enable = true;
    packageFallback = true;
  };

  plugins.lsp.servers.denols = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft =
    let
      formatters.__raw = /* lua */ "function() return Utils.formatter.pick({ 'oxfmt', 'deno_fmt', 'eslint_d', 'prettierd' }) end";
    in
    {
      javascript = formatters;
      javascriptreact = formatters;
      typescript = formatters;
      typescriptreact = formatters;
    };
}
