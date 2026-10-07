{ pkgs, ... }:

{
  plugins.lsp.servers.unocss = {
    enable = true;
    packageFallback = true;

    package = pkgs.unocss-language-server;
  };
}
