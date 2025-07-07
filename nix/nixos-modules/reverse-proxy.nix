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
        type = types.attrsOf (
          types.submodule {
            options = {
              serverAliases = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = "Additional domain names for this virtual host";
              };

              upstream = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Upstream server for reverse proxy (e.g., 'localhost:8080' or 'euler:9090')";
              };

              useACMEHost = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Use certificates from this ACME host";
              };

              extraConfig = mkOption {
                type = types.str;
                default = "";
                description = "Extra Caddy configuration for this virtual host";
                example = ''
                  bind tailscale/linkding
                  tailscale_auth
                '';
              };
            };
          }
        );
        default = { };
        description = "Virtual hosts configuration for Caddy";
      };

      permitCertUid = mkOption {
        type = types.str;
        default = "caddy";
        description = "User ID that can manage Tailscale certificates";
      };

      firewallPorts = mkOption {
        type = types.listOf types.port;
        default = [
          80
          443
        ];
        description = "Firewall ports to open for the reverse proxy";
      };
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      virtualHosts = mapAttrs (name: vhost: {
        serverAliases = vhost.serverAliases;
        useACMEHost = vhost.useACMEHost;
        extraConfig =
          optionalString (vhost.upstream != null) "reverse_proxy ${vhost.upstream}"
          + optionalString (vhost.extraConfig != "") (
            (if vhost.upstream != null then "\n" else "") + vhost.extraConfig
          );
      }) cfg.virtualHosts;
    };

    services.tailscale.permitCertUid = cfg.permitCertUid;

    networking.firewall.allowedTCPPorts = cfg.firewallPorts;
  };
}
