{ pkgs, ... }:

{
  plugins.scrollview = {
    enable = true;
    package = pkgs.vimPlugins.nvim-scrollview.overrideAttrs (old: {
      src = pkgs.fetchFromGitHub {
        owner = "dstein64";
        repo = "nvim-scrollview";
        # Commit: Add a new option: scrollview_signs_max_per_row_by_group
        # Resolved: dstein64/nvim-scrollview#158
        rev = "ff8c8b76170f0062aa00f2609b48235e9cc3d131";
        hash = "sha256-MwgaUVYjqLVwZ5NVEgJWIRWA0+Wx2wrekTRmAVVM0zU=";
      };
    });

    settings = {
      excluded_filetypes = [
        "neo-tree"
      ];

      signs_on_startup = [
        "cursor"
        "marks"
        "folds"
        "loclist"
        "search"
        "changelist"
        "diagnostics"
        "conflicts"
        "keywords"
      ];

      cursor_symbol = "-";

      diagnostics_hint_symbol = "!";
      diagnostics_info_symbol = "!";
      diagnostics_warn_symbol = "!";
      diagnostics_error_symbol = "!";

      signs_max_per_row_by_group = {
        diagnostics = 1;
      };
    };
  };
}
