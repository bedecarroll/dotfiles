{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      ansible
      ansible-lint
      ansible-later
      awscli2
      terraform
      terraformer
    ];
  };
}

