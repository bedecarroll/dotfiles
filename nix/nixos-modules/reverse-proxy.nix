{ lib, config, ... }:
with lib;
let
  cfg = config.reverseProxy;
in
{
  options = {
    reverseProxy = {
      enable = mkEnableOption "Enable Caddy reverse proxy with Tailscale integration";
      
      virtualHosts = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            extraConfig = mkOption {
              type = types.str;
              description = "Extra Caddy configuration for this virtual host";
              example = ''
                bind tailscale/linkding
                tailscale_auth
                reverse_proxy 100.64.0.1:9090
              '';
            };
          };
        });
        default = {};
        description = "Virtual hosts configuration for Caddy";
      };

      permitCertUid = mkOption {
        type = types.str;
        default = "caddy";
        description = "User ID that can manage Tailscale certificates";
      };

      firewallPorts = mkOption {
        type = types.listOf types.port;
        default = [ 80 443 ];
        description = "Firewall ports to open for the reverse proxy";
      };
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = cfg.virtualHosts;
    };

    services.tailscale.permitCertUid = cfg.permitCertUid;

    networking.firewall.allowedTCPPorts = cfg.firewallPorts;
  };
}