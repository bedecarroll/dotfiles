{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      vim
      neovim
      nano
    ];
  };
}

