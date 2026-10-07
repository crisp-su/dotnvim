{
  plugins.rustaceanvim = {
    enable = true;

    settings = {
    };
  };

  dependencies.rust-analyzer = {
    enable = true;
    packageFallback = true;
  };
}
