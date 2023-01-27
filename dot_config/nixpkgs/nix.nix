{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      nixpkgs-fmt
    ];
  };
}

