{ lib, config, ... }:
with lib;
let
  cfg = config.vpn;
in
{

  options = {
    vpn.enable = mkEnableOption "Standard VPN config";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    services.tailscale.openFirewall = true;
  };
}
