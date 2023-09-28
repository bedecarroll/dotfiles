{ config, pkgs, ... }:

{
  config = {
    # Help docs and cheatsheets
    home.packages = with pkgs; [
      man
      cheat
      tealdeer
    ];
  };
}

