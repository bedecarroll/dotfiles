{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      alacritty
      kitty
    ];
  };
}

