{
  inputs' ? { },
  pkgs ? import <nixpkgs> { },
  ...
}:

pkgs.mkShell {
  packages = with pkgs; [
    nil
    statix
    nixfmt
    stylua-fork
    prettier
  ];

  shellHook = /* bash */ ''
    echo -e "\033[36m# --------------> [ NIX SHELL ] <-------------- #\033[0m"
  '';
}
