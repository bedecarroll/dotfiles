{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.greetd;
in
{
  options = {
    greetd.enable = mkEnableOption "greetd login manager";
  };
  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.hyprland}/bin/Hyprland";
          user = "greeter";
        };
      };
    };
  };
}
