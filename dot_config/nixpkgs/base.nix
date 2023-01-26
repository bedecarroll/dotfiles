{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      tmux
      neovim
      atuin
    ];
  };
}

