{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.video;
in
{

  options = {
    video.enable = mkEnableOption "video stuff";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      mpv
      yt-dlp
      ffmpeg
    ];
  };
}
