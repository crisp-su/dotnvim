{ lib, pkgs, ... }:

{
  # Fallback tooling for plain scripts when a project does not pin versions.
  extraPackagesAfter = with pkgs; [
    ruff
    pyright
  ];

  # Python linters are selected per-buffer by `Utils.python`.
  plugins.lint.lintersByFt.python = [ ];

  plugins.conform-nvim.settings.formatters_by_ft.python =
    lib.nixvim.mkRaw
      /* lua */ "function(bufnr) return Utils.python.formatters(bufnr) end";

  autoCmd = [
    {
      group = "Auto";
      event = "FileType";
      pattern = "python";
      callback = lib.nixvim.mkRaw /* lua */ "function(args) Utils.python.lint_buffer(args.buf) end";
    }

    {
      group = "Auto";
      event = "BufWritePre";
      pattern = "*.py";
      callback = lib.nixvim.mkRaw /* lua */ "function(args) Utils.python.before_save(args.buf) end";
    }

    {
      group = "Auto";
      event = [
        "BufWritePost"
        "InsertLeave"
      ];
      pattern = "*.py";
      callback = lib.nixvim.mkRaw /* lua */ "function(args) Utils.python.lint_buffer(args.buf) end";
    }
  ];
}
