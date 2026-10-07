{ pkgs, ... }:

{
  extraPackagesAfter = with pkgs; [
    fish
  ];

  plugins.lsp.servers.fish_lsp = {
    enable = true;
    packageFallback = true;
  };

  plugins.conform-nvim.settings.formatters_by_ft.fish = [ "fish_indent" ];

  plugins.lint.lintersByFt.fish = [ "fish" ];

  autoCmd = [
    {
      group = "Auto";
      event = "FileType";
      pattern = "fish";
      callback.__raw = /* lua */ ''
        function()
          vim.opt_local.expandtab = true
          vim.opt_local.shiftwidth = 4
          vim.opt_local.softtabstop = 4
          vim.opt_local.tabstop = 4
        end
      '';
    }
  ];
}
