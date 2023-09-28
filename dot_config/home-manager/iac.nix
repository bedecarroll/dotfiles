{ config, pkgs, ... }:

{
  config = {
    # Commonly needed IaC packages
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

