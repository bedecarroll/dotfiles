{ config, pkgs, ... }:

{
  config = {
    # Terminals
    home.packages = with pkgs; [ alacritty kitty ];
  };
}

