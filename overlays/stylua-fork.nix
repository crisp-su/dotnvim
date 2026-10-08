final: prev:

{
  stylua-fork = prev.rustPlatform.buildRustPackage {
    pname = "stylua-fork";
    version = "2.5.2";

    src = prev.fetchFromGitHub {
      owner = "crisp-su";
      repo = "StyLua";
      rev = "312cd60b069150746a43706ab7bac2ecadc10b9e"; # format-expression branch HEAD
      hash = "sha256-Bztuf76DgYYmW2KQkJSkNhIe0yBcoMZyCK4fk/fQBDg=";
    };

    cargoHash = "sha256-x8+6kiezk2cTT8wR5CmMcNakDhc1Ohcb0AsIYH6kybw=";

    # remove cargo config so it can find the linker on aarch64-unknown-linux-gnu
    postPatch = ''
      rm .cargo/config.toml
    '';

    buildFeatures = [
      "lua54"
      "luajit"
      "luau"
    ];

    meta = {
      description = "Opinionated Lua code formatter (crisp-su `format-expression` fork)";
      homepage = "https://github.com/crisp-su/StyLua";
      license = prev.lib.licenses.mpl20;
      mainProgram = "stylua";
    };
  };
}
