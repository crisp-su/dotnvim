{ pkgs, lib, ... }:

{
  extraPackagesAfter = with pkgs; [
    oxfmt
    deno
    eslint_d
    prettierd
  ];

  plugins.lsp.servers.volar = {
    enable = true;
    packageFallback = true;
  };

  plugins.lsp.servers.eslint = {
    enable = true;
    packageFallback = true;

    filetypes = lib.mkAfter [
      "vue"
    ];
  };

  plugins.lsp.servers.oxlint = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.vue.__raw =
    "function() return Utils.formatter.pick({ 'oxfmt', 'deno_fmt', 'eslint_d', 'prettierd' }) end";
}
