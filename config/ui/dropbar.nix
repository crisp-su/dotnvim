{ lib, ... }:

{
  plugins.dropbar = {
    enable = true;

    settings = {
      bar = {
        update_debounce = 16;

        # `BufModifiedSet` is rejected by current Neovim nightly, causing dropbar setup to fail during startup.
        update_events.buf = [
          "FileChangedShellPost"
          "TextChanged"
          "ModeChanged"
          "BufWritePost"
        ];

        sources = lib.nixvim.mkRaw /* lua */ ''
          function(buf, _)
            local sources = require('dropbar.sources')
            local utils = require("dropbar.utils")

            if vim.bo[buf].ft == 'markdown' then
              return { sources.markdown }
            end
            if vim.bo[buf].buftype == 'terminal' then
              return { sources.terminal }
            end

            return { utils.source.fallback({ sources.lsp, sources.treesitter }) }
          end
        '';
      };
    };
  };

  colorschemes.catppuccin.settings.integrations.dropbar = {
    enabled = true;
    color_mode = true;
  };
}
