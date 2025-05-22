{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.audio;
in
{

  options = {
    audio.enable = mkEnableOption "Audio settings";
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
    environment.systemPackages = with pkgs; [
      pavucontrol
    ];
  };
}
