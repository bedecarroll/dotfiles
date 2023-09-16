{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      nodejs
      # Switch back when bun is upgraded upstream
      #bun
    ];
  };
}

