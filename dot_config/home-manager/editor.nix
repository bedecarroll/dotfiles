{ config, pkgs, ... }:

{
  config = {
    # Text editors
    home.packages = with pkgs; [ nano ];
  };
}

