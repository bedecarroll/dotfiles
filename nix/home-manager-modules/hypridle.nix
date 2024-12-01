{ lib, config, ... }:
with lib;
let
  cfg = config.hypridle;
in
{
  options = {
    hypridle.enable = mkEnableOption "Hypridle config";
  };

  config = mkIf cfg.enable {
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = [
          {
            on-timeout = "loginctl lock-session";
            timeout = 360;
          }
          {
            on-resume = "hyprctl dispatch dpms on";
            on-timeout = "hyprctl dispatch dpms off";
            timeout = 420;
          }
        ];
      };
    };
  };
}
