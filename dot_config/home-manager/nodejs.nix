{ config, pkgs, ... }:

{
  config = {
    # JS/TS tooling
    home.packages = with pkgs; [
      nodejs
      # Switch back when bun is upgraded upstream
      #bun
    ];
  };
}

