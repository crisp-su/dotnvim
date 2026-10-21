{
  opts = {
    termguicolors = true;
    # winborder = "rounded";
    fillchars = {
      eob = " ";
      foldclose = "+";
      foldopen = "-";
      foldsep = "┆";
    };

    showmode = true;
    laststatus = 3;
    number = true;
    relativenumber = true;
    cursorline = true;
    list = true;
    conceallevel = 2;

    timeoutlen = 300;
    updatetime = 100;

    scrolloff = 10;
    sidescrolloff = 16;

    clipboard = "unnamedplus";

    expandtab = true;
    tabstop = 2;
    shiftwidth = 2;
    shiftround = true;
    autoindent = true;
    smartindent = true;

    autowrite = false;
    confirm = true;
    backupcopy = "yes";
    swapfile = false;
    undofile = true;
    undolevels = 25600;

    ignorecase = true;
    smartcase = true;
    incsearch = true;

    foldlevel = 256;
    foldlevelstart = 256;

    sessionoptions = [
      "globals"
      "buffers"
      "tabpages"
      "winsize"
      "skiprtp"
      "curdir"
      # "folds"
      "help"
    ];
  };
}
