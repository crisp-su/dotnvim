{ lib, lib', ... }:

{
  plugins.snacks.settings.lazygit = {
    configure = true;
  };

  plugins.which-key.settings.spec =
    with lib'.utils.wk;
    with lib'.icons;
    [
      (mkSpec
        [
          "<leader>gl"
          (lib.nixvim.mkRaw /* lua */ "function() Snacks.lazygit() end")
        ]
        {
          desc = "Lazygit";
          mode = modes.interact;
          icon = {
            icon = common.Lazygit.line;
            color = "blue";
          };
        }
      )
    ];
}
