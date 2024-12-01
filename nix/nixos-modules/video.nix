{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.video;
in
{

  options = {
    video.enable = mkEnableOption "video settings";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      glxinfo
      libva-utils
      vdpauinfo
    ];
    hardware.graphics = {
      enable = true;
    };
  };
}
