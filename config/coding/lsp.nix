{ lib', ... }:

{
  plugins.lsp = {
    enable = true;

    inlayHints = true;
  };

  plugins.which-key.settings.spec =
    with lib'.utils.wk;
    with lib'.icons;
    let
      languageIcon = {
        __raw = /* lua */ "Utils.lsp.language_icon()";
      };
    in
    [
      # Hide default lsp keymaps (Neovim 0.10+)
      (mkSpecHidden "gra")
      (mkSpecHidden "gri")
      (mkSpecHidden "grn")
      (mkSpecHidden "grr")
      (mkSpecHidden "grt")

      (mkSpec
        [
          "<leader>cl"
          { __raw = /* lua */ "function() Snacks.picker.lsp_config() end"; }
        ]
        {
          desc = "Lsp Info";
          icon = languageIcon;
          mode = modes.interact;
        }
      )

      (mkSpec
        [
          "gd"
          { __raw = /* lua */ "function() vim.lsp.buf.definition() end"; }
        ]
        {
          desc = "Go to Definition";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('definition')";
          refresh = true;
        }
      )
      (mkSpec
        [
          "gr"
          { __raw = /* lua */ "function() vim.lsp.buf.references() end"; }
        ]
        {
          desc = "Go to References";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('references')";
          refresh = true;
        }
      )
      (mkSpec
        [
          "gI"
          { __raw = /* lua */ "function() vim.lsp.buf.implementation() end"; }
        ]
        {
          desc = "Go to Implementation";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('implementation')";
          refresh = true;
        }
      )
      (mkSpec
        [
          "gY"
          { __raw = /* lua */ "function() vim.lsp.buf.type_definition() end"; }
        ]
        {
          desc = "Go to Type Definition";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('typeDefinition')";
          refresh = true;
        }
      )
      (mkSpec
        [
          "gD"
          { __raw = /* lua */ "function() vim.lsp.buf.declaration() end"; }
        ]
        {
          desc = "Go to Declaration";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('declaration')";
          refresh = true;
        }
      )
      (mkSpec
        [
          "gO"
          { __raw = /* lua */ "function() vim.lsp.buf.document_symbol() end"; }
        ]
        {
          desc = "List All Symbols";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('documentSymbol')";
          refresh = true;
        }
      )

      (mkSpec
        [
          "K"
          { __raw = /* lua */ "function() vim.lsp.buf.hover() end"; }
        ]
        {
          desc = "Hover";
          icon = languageIcon;
          mode = modes.interact;
        }
      )
      (mkSpec
        [
          "gK"
          { __raw = /* lua */ "function() vim.lsp.buf.signature_help() end"; }
        ]
        {
          desc = "Signature Help";
          icon = languageIcon;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('signatureHelp')";
          refresh = true;
        }
      )

      (mkSpec
        [
          "<leader>cr"
          { __raw = /* lua */ "function() vim.lsp.buf.rename() end"; }
        ]
        {
          desc = "Rename";
          icon = common.Input.line;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('rename')";
          refresh = true;
        }
      )
      (mkSpec
        [
          "<leader>cR"
          { __raw = /* lua */ "function() Snacks.rename.rename_file() end"; }
        ]
        {
          desc = "Rename File";
          icon = common.Input.line;
          mode = modes.interact;
          cond.__raw = /* lua */ "Utils.lsp.has_capability('workspace/willRenameFiles')";
          refresh = true;
        }
      )
    ];

  autoCmd = [
    {
      group = "WhichKeyUtil";
      desc = "Refresh key mappings when LSP state changes";
      event = [
        "LspAttach"
        "LspDetach"
      ];
      callback.__raw = /* lua */ "function() Utils.wk.refresh() end";
    }
  ];
}
