{
  config,
  lib,
  lib',
  ...
}:

{
  plugins.persistence = {
    enable = true;

    settings = {
    };
  };

  plugins.which-key.settings.spec = with lib'.utils.wk; [
    (mkSpec
      [
        "<leader>qs"
        (lib.nixvim.mkRaw /* lua */ "function() require('persistence').load() end")
      ]
      {
        desc = "Restore Session";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<leader>qS"
        (lib.nixvim.mkRaw /* lua */ "function() require('persistence').select() end")
      ]
      {
        desc = "Select Session";
        mode = modes.interact;
      }
    )
    (mkSpec
      [
        "<leader>qd"
        (lib.nixvim.mkRaw /* lua */ "function() require('persistence').stop() end")
      ]
      {
        desc = "Don't Save Current Session";
        mode = modes.interact;
      }
    )
  ];

  autoCmd = lib.mkIf config.plugins.scope.enable [
    {
      group = "HackFix";
      desc = "Save scope state before persistence session save";
      event = "User";
      pattern = "PersistenceSavePre";
      callback = lib.nixvim.mkRaw /* lua */ ''
        function()
          if vim.fn.exists(':ScopeSaveState') == 2 then
            vim.cmd.ScopeSaveState()
          end
        end
      '';
    }

    {
      group = "HackFix";
      desc = "Reset scope state before persistence session load";
      event = "User";
      pattern = "PersistenceLoadPre";
      callback = lib.nixvim.mkRaw /* lua */ "function() vim.g.ScopeState = nil end";
    }

    {
      group = "HackFix";
      desc = "Restore scope state after persistence session load";
      event = "User";
      pattern = "PersistenceLoadPost";
      callback = lib.nixvim.mkRaw /* lua */ ''
        function()
          if vim.fn.exists(':ScopeLoadState') == 2 then
            vim.cmd.ScopeLoadState()
          end
        end
      '';
    }
  ];
}
