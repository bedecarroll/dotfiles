{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      du-dust
      duf
      broot
      btdu
    ];
  };
}
