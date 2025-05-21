{ lib, config, ... }:
with lib;
let
  cfg = config.ntp;
in
{
  options = {
    ntp.enable = mkEnableOption "NTP time servers";
  };
  config = mkIf cfg.enable {
    networking.timeServers = [ "time.cloudflare.com" ];
  };
}
