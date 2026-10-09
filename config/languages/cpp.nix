{ pkgs, lib, ... }:

{
  extraPackagesAfter = with pkgs; [
    clang-tools
  ];

  plugins.lsp.servers.clangd = {
    enable = true;
    packageFallback = true;

    cmd = [
      "clangd"
      "--background-index"
      "--clang-tidy"
      "--header-insertion=iwyu"
      "--completion-style=detailed"
    ];
  };

  plugins.lsp.servers.neocmake = {
    enable = true;
    packageFallback = true;
  };

  plugins.lint.lintersByFt = {
    c = [ ];
    cpp = [ ];
  };

  plugins.conform-nvim.settings.formatters_by_ft = {
    c = [ "clang-format" ];
    cpp = [ "clang-format" ];
    cuda = [ "clang-format" ];
    objc = [ "clang-format" ];
    objcpp = [ "clang-format" ];
  };

  autoCmd = [
    {
      group = "Auto";
      event = "FileType";
      pattern = [
        "c"
        "cpp"
      ];
      callback =
        lib.nixvim.mkRaw
          /* lua */ "function(args) Utils.linter.set_external_linters(vim.bo[args.buf].filetype, { 'clangtidy' }) end";
    }
  ];
}
