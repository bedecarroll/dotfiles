{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.golink;
in
{
  options = {
    golink = {
      enable = mkEnableOption "Enable Golink URL shortener service";
      
      image = mkOption {
        type = types.str;
        default = "ghcr.io/tailscale/golink:main";
        description = "Docker image for Golink";
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Port to expose Golink on";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/golink";
        description = "Directory to store Golink data";
      };

      backupDir = mkOption {
        type = types.str;
        default = "/backup/golink";
        description = "Directory to store Golink backups";
      };

      environmentFiles = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of environment files to load";
      };

      enableBackups = mkOption {
        type = types.bool;
        default = true;
        description = "Enable daily backups of Golink data";
      };

      enableAutoUpdate = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic container updates";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.golink = {
      image = cfg.image;
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [
        "${cfg.dataDir}:/home/nonroot"
      ];
      environment = {};
      environmentFiles = cfg.environmentFiles;
      autoStart = true;
    };

    virtualisation.oci-containers.backend = "podman";

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 65532 65532 -"
    ] ++ optionals cfg.enableBackups [
      "d ${cfg.backupDir} 0755 root root -"
    ];

    systemd.services.golink-backup = mkIf cfg.enableBackups {
      description = "Backup golink data";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.rsync}/bin/rsync -av ${cfg.dataDir}/ ${cfg.backupDir}/";
      };
    };
    
    systemd.timers.golink-backup = mkIf cfg.enableBackups {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };
  };
}