{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.eternal-terminal;
in
{
  options.services.eternal-terminal = {
    enable = mkEnableOption "Eternal Terminal server";

    port = mkOption {
      type = types.port;
      default = 2022;
      description = "The port the server should listen on";
    };

    logSize = mkOption {
      type = types.int;
      default = 20971520;
      description = "The maximum log size";
    };

    silent = mkOption {
      type = types.bool;
      default = false;
      description = "If enabled, disables all logging";
    };

    verbosity = mkOption {
      type = types.int;
      default = 0;
      description = "The verbosity level (0-9)";
    };
  };

  config = mkIf cfg.enable {
    services.eternal-terminal = {
      enable = true;
      port = cfg.port;
      logSize = cfg.logSize;
      silent = cfg.silent;
      verbosity = cfg.verbosity;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}