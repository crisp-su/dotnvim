{ inputs, self }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dotnvim;

  requiredOverlays = [
    inputs.neovim-nightly-overlay.overlays.default
    self.overlays.default
  ];

  configuredOverlays = lib.optionals cfg.selfContainedOverlays requiredOverlays ++ cfg.extraOverlays;
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options.programs.dotnvim = {
    enable = lib.mkEnableOption "Whether to enable Suu's configured Neovim.";

    useFlakeNixpkgs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to evaluate nixvim with this flake's `nixpkgs` input.
        When enabled, this module sets `programs.nixvim.nixpkgs.pkgs` from dotnvim's pinned nixpkgs.
      '';
    };

    selfContainedOverlays = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether to include dotnvim's required overlays for nixvim package evaluation.
        Disable this if you manage overlays externally and want full control over nixvim's package set.
      '';
    };

    extraOverlays = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [ ];
      description = "Additional overlays appended when constructing nixvim's package set.";
    };

    extraImports = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
      description = "Additional nixvim modules appended to `programs.nixvim.imports`.";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Settings passed to dotnvim's nixvim module.";
    };

    defaultEditor = lib.mkEnableOption "nixvim as the default editor";

    vimdiffAlias = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Alias `vimdiff` to `nvim -d`.
      '';
    };

    vimAlias = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Symlink `vim` to `nvim`.";
    };

    viAlias = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Symlink `vi` to `nvim`.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !(cfg.useFlakeNixpkgs && config.programs.nixvim.nixpkgs.useGlobalPackages);
            message = ''
              `programs.dotnvim.useFlakeNixpkgs` cannot be used with
              `programs.nixvim.nixpkgs.useGlobalPackages = true`.
              Disable `useFlakeNixpkgs` or use non-global nixvim packages.
            '';
          }
        ];

        programs.nixvim = {
          enable = true;

          imports = [
            self.nixvimModules.default
            { dotnvim.settings = cfg.settings; }
          ]
          ++ cfg.extraImports;

          defaultEditor = lib.mkDefault cfg.defaultEditor;

          vimdiffAlias = lib.mkDefault cfg.vimdiffAlias;
          vimAlias = lib.mkDefault cfg.vimAlias;
          viAlias = lib.mkDefault cfg.viAlias;
        };
      }

      (lib.mkIf cfg.useFlakeNixpkgs {
        programs.nixvim.nixpkgs = {
          useGlobalPackages = lib.mkDefault false;
          pkgs = import inputs.nixpkgs {
            inherit (pkgs.stdenv.hostPlatform) system;
            overlays = configuredOverlays;
          };
        };
      })

      (lib.mkIf (!cfg.useFlakeNixpkgs && configuredOverlays != [ ]) {
        programs.nixvim.nixpkgs.overlays = configuredOverlays;
      })
    ]
  );
}
