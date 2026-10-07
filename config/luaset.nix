{
  config,
  lib,
  ...
}:

{
  extraConfigLuaPre = lib.mkBefore ''
    Utils = require('utils')

    Snacks = Utils.lazy_require('snacks.nvim')
  '';

  # Expose the bin dirs of all fallback packages (the merged `extraPackagesAfter`)
  # to `Utils.toolchain`, so tool selection can tell fallback binaries apart
  # from environment-provided ones.
  extraConfigLua = ''
    Utils.toolchain.fallback_bins = ${
      lib.nixvim.toLuaObject (map (package: "${package}/bin") (lib.unique config.extraPackagesAfter))
    }
  '';
}
