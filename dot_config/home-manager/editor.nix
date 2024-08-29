{ pkgs, ... }:

{
  config = {
    # Text editors
    home.packages = with pkgs; [ neovim nano glow ];
  };
}

