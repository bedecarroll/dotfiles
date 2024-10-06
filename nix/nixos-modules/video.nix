{
  config,
  lib,
  pkgs,
  pkgs-unstable,
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
    hardware.opengl = {
      enable = true;
      extraPackages = [ pkgs-unstable.vpl-gpu-rt ];
    };
  };
}
