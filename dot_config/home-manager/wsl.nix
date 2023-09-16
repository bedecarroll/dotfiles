{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      topgrade
      ffmpeg
    ];
  };
}

