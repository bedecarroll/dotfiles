{ config, pkgs, ... }:

{
  config = {
    # Packages that all WSL boxes need
    home.packages = with pkgs; [
      topgrade
      ffmpeg
    ];
  };
}

