{ pkgs, ... }:

{
  dependencies.rust-analyzer = {
    enable = true;
    packageFallback = true;
  };

  extraPackagesAfter = with pkgs; [
    cargo
    rustc
    clippy
    rustfmt
  ];

  plugins.rustaceanvim = {
    enable = true;

    settings = {
    };
  };
}
