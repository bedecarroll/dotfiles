{ pkgs, ... }:

{
  config = {
    # Terminals
    home.packages = with pkgs; [ wezterm alacritty kitty ];
  };
}

