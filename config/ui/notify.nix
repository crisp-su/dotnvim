{ lib', ... }:

{
  plugins.notify = {
    enable = true;

    settings = {
      fps = 120;
      top_down = false;
      stages = "slide";
      timeout = 5000;

      icons = with lib'.icons.notification; {
        INFO = Information.fill;
        WARN = Warning.fill;
        ERROR = Error.fill;
        DEBUG = Debug.fill;
        TRACE = Trace.fill;
      };

      render.__raw = /* lua */ "require('d.notify_render')";
    };
  };

  extraConfigLua = /* lua */ ''
    local function patch_notify_highlights()
      local levels = { 'INFO', 'WARN', 'ERROR', 'DEBUG', 'TRACE' }

      for _, level in ipairs(levels) do
        local name = 'Notify' .. level .. 'Title'
        local hl = vim.api.nvim_get_hl(0, { name = name })

        if hl then
          hl.italic = false
          vim.api.nvim_set_hl(0, name, hl)
        end
      end
    end

    patch_notify_highlights()

    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = patch_notify_highlights,
    })
  '';

  colorschemes.catppuccin.settings.integrations.notify = true;
}
