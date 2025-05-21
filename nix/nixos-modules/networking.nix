{ lib, config, ... }:
with lib;
let
  cfg = config.networking;
in
{
  options = {
    networking.enable = mkEnableOption "networking services (networkmanager, mtr)";
  };
  config = mkIf cfg.enable {
    networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
    programs.mtr.enable = true; # enable setuid wrapper so we don't need to sudo
  };
}
