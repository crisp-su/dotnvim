{
  opts = {
    numberwidth = 1;
    signcolumn = "yes";
    foldcolumn = "1";
  };

  plugins.statuscol = {
    enable = true;

    lazyLoad.settings.event = [
      "DeferredUIEnter"
    ];

    settings = {
      ft_ignore = [
        "alpha"
        "noice"
        "notify"
        "neo-tree"
        "neo-tree-popup"
        "oil_preview"
      ];

      relculright = true;

      segments = [
        # Fold Signs
        {
          text = [
            {
              __raw = /* lua */ "require('statuscol.builtin').foldfunc";
            }
          ];
          click = "v:lua.ScFa";
        }

        # Space
        {
          text = [ " " ];
        }

        # Common Signs
        {
          sign = {
            name = [ ".*" ];
            text = [ ".*" ];
            namespace = [ ".*" ];
            maxwidth = 1;
            colwidth = 2;
          };
          click = "v:lua.ScSa";
        }

        # Line Numbers
        {
          condition = [
            {
              __raw = /* lua */ "require('statuscol.builtin').not_empty";
            }
          ];
          text = [
            {
              __raw = /* lua */ "require('statuscol.builtin').lnumfunc";
            }
          ];
          click = "v:lua.ScLa";
        }

        # Space
        {
          text = [ " " ];
        }

        # Gitsigns
        {
          sign = {
            namespace = [ "gitsign" ];
            maxwidth = 1;
            colwidth = 1;
            wrap = true;
          };
          click = "v:lua.ScSa";
        }

        # Space
        {
          text = [ " " ];
        }
      ];
    };
  };

  autoCmd = [
    {
      group = "HackFix";
      desc = "Disable statuscol in filetype ignored buffers";
      event = [
        "BufEnter"
        "BufWinEnter"
      ];
      callback.__raw = /* lua */ ''
        function()
          if not _G.__statuscol_cfg_cache then
            local ok, m = pcall(require, 'statuscol')
            if not ok then
              return
            end

            for i = 1, 20 do
              local name, value = debug.getupvalue(m.setup, i)
              if name == 'cfg' then
                _G.__statuscol_cfg_cache = value
                break
              end
            end
          end

          local cfg = _G.__statuscol_cfg_cache
          if not cfg or not cfg.ft_ignore then
            return
          end

          if vim.bo.buftype == 'nofile' or vim.tbl_contains(cfg.ft_ignore, vim.bo.filetype) then
            vim.opt_local.statuscolumn = '''
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.foldcolumn = '0'
          end
        end
      '';
    }

    {
      group = "HackFix";
      desc = "Disable statuscol for Neogit buffers";
      event = [ "FileType" ];
      pattern = [ "Neogit*" ];
      callback.__raw = /* lua */ ''
        function(args)
          vim.schedule(function()
            vim.opt_local.statuscolumn = '''
            vim.opt_local.signcolumn = 'no'
            vim.opt_local.foldcolumn = '0'
          end)
        end
      '';
    }
  ];
}
