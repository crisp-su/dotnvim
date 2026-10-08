{
  perSystem =
    { config, pkgs, ... }:
    let
      checkSrc = pkgs.lib.cleanSource ../.;

      mkCheck =
        name: nativeBuildInputs: checkCommand:
        pkgs.runCommand name
          {
            src = checkSrc;
            inherit nativeBuildInputs;
          }
          ''
            cd "$src"
            ${checkCommand}
            touch "$out"
          '';
    in
    {
      checks = {
        nvimBuild = config.packages.default;

        nvimStartup = mkCheck "nvim-startup-check" [ config.packages.default ] /* bash */ ''
          export HOME="$TMPDIR/home"
          export XDG_CACHE_HOME="$TMPDIR/cache"
          export XDG_CONFIG_HOME="$TMPDIR/config"
          export XDG_DATA_HOME="$TMPDIR/data"
          export XDG_STATE_HOME="$TMPDIR/state"

          mkdir -p "$HOME" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"

          nvim --headless -n -i NONE "+qa"
        '';

        nixfmt = mkCheck "nixfmt-check" [ pkgs.nixfmt ] "nixfmt --check .";
        prettier = mkCheck "prettier-check" [ pkgs.prettier ] "prettier --check .";
        statix = mkCheck "statix-check" [ pkgs.statix ] "statix check .";
        stylua = mkCheck "stylua-check" [ pkgs.stylua-fork ] "stylua --check .";
      };
    };
}
