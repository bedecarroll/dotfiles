{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      man
      cheat
      tldr
    ];
  };
}

