{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      ansible
      awscli2
      terraform
      terraformer
    ];
  };
}

