{ config, pkgs, ... }:

{
  config = {
    # Text editors (expected everywhere)
    home.packages = with pkgs; [
      vim
      neovim
      nano
    ];
  };
}

