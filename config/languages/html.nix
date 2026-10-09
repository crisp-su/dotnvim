{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    oxfmt
    deno
    prettierd
  ];

  plugins.conform-nvim.settings.formatters_by_ft.html.__raw =
    /* lua */ "function() return Utils.formatter.pick({ 'oxfmt', 'deno_fmt', 'prettierd' }) end";
}
