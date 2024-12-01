{ lib, config, ... }:
with lib;
let
  cfg = config.waybar;
in
{
  options = {
    waybar.enable = mkEnableOption "Waybar config";
  };

  config = mkIf cfg.enable {

  };
}
