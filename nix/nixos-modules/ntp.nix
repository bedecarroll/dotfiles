{ lib, config, ... }:
with lib;
let
  cfg = config.ntp;
in
{
  options = {
    ntp.enable = mkEnableOption "NTP time servers";
    ntp.servers = mkOption {
      type = types.listOf types.str;
      default = [ "time.cloudflare.com" ];
      description = "NTP servers to use";
    };
  };
  config = mkIf cfg.enable {
    networking.timeServers = cfg.servers;
  };
}
