{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    wsl.enable = lib.mkEnableOption "pkgs need on wsl installs";
  };

  config = lib.mkIf config.wsl.enable {
    home.packages = with pkgs; [
      topgrade
      ffmpeg
    ];
  };
}
