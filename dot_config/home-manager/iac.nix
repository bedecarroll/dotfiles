{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      terraform
      terraformer
    ];
  };
}

