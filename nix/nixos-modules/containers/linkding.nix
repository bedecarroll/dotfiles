{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.linkding;
in
{
  options = {
    linkding = {
      enable = mkEnableOption "Enable Linkding bookmark manager service";

      image = mkOption {
        type = types.str;
        default = "sissbruecker/linkding:latest";
        description = "Docker image for Linkding";
      };

      port = mkOption {
        type = types.port;
        default = 9090;
        description = "Port to expose Linkding on";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/linkding";
        description = "Directory to store Linkding data";
      };

      backupDir = mkOption {
        type = types.str;
        default = "/backup/linkding";
        description = "Directory to store Linkding backups";
      };

      superuserName = mkOption {
        type = types.str;
        default = "admin";
        description = "Linkding superuser name";
      };

      superuserPassword = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Linkding superuser password (use environmentFiles for secrets)";
      };

      contextPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional context path for the application";
      };

      enableAuthProxy = mkOption {
        type = types.bool;
        default = false;
        description = "Enable authentication proxy support";
      };

      authProxyUsernameHeader = mkOption {
        type = types.str;
        default = "Remote-User";
        description = "Header for auth proxy username";
      };

      authProxyLogoutUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Logout URL for auth proxy";
      };

      disableBackgroundTasks = mkOption {
        type = types.bool;
        default = false;
        description = "Disable background tasks";
      };

      disableUrlValidation = mkOption {
        type = types.bool;
        default = false;
        description = "Disable URL validation";
      };

      csrfTrustedOrigins = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Trusted origins for CSRF protection";
      };

      database = {
        engine = mkOption {
          type = types.enum [
            "sqlite"
            "postgres"
          ];
          default = "sqlite";
          description = "Database engine to use";
        };

        name = mkOption {
          type = types.str;
          default = "linkding";
          description = "Database name (for PostgreSQL)";
        };

        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Database username (for PostgreSQL)";
        };

        password = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Database password (use environmentFiles for secrets)";
        };

        host = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Database hostname (for PostgreSQL)";
        };

        port = mkOption {
          type = types.nullOr types.port;
          default = null;
          description = "Database port (for PostgreSQL)";
        };

        options = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Additional database connection options";
        };
      };

      environmentFiles = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "List of environment files to load";
      };

      enableBackups = mkOption {
        type = types.bool;
        default = true;
        description = "Enable daily backups of Linkding data";
      };

      enableAutoUpdate = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic container updates";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.linkding = {
      image = cfg.image;
      ports = [ "${toString cfg.port}:9090" ];
      volumes = [
        "${cfg.dataDir}:/etc/linkding/data"
      ];
      environment =
        {
          LD_SUPERUSER_NAME = cfg.superuserName;
        }
        // optionalAttrs (cfg.superuserPassword != null) {
          LD_SUPERUSER_PASSWORD = cfg.superuserPassword;
        }
        // optionalAttrs (cfg.contextPath != null) {
          LD_CONTEXT_PATH = cfg.contextPath;
        }
        // optionalAttrs cfg.enableAuthProxy {
          LD_ENABLE_AUTH_PROXY = "True";
          LD_AUTH_PROXY_USERNAME_HEADER = cfg.authProxyUsernameHeader;
        }
        // optionalAttrs (cfg.authProxyLogoutUrl != null) {
          LD_AUTH_PROXY_LOGOUT_URL = cfg.authProxyLogoutUrl;
        }
        // optionalAttrs cfg.disableBackgroundTasks {
          LD_DISABLE_BACKGROUND_TASKS = "True";
        }
        // optionalAttrs cfg.disableUrlValidation {
          LD_DISABLE_URL_VALIDATION = "True";
        }
        // optionalAttrs (cfg.csrfTrustedOrigins != [ ]) {
          LD_CSRF_TRUSTED_ORIGINS = concatStringsSep "," cfg.csrfTrustedOrigins;
        }
        // optionalAttrs (cfg.database.engine == "postgres") {
          LD_DB_ENGINE = "postgres";
          LD_DB_DATABASE = cfg.database.name;
        }
        // optionalAttrs (cfg.database.user != null) {
          LD_DB_USER = cfg.database.user;
        }
        // optionalAttrs (cfg.database.password != null) {
          LD_DB_PASSWORD = cfg.database.password;
        }
        // optionalAttrs (cfg.database.host != null) {
          LD_DB_HOST = cfg.database.host;
        }
        // optionalAttrs (cfg.database.port != null) {
          LD_DB_PORT = toString cfg.database.port;
        }
        // optionalAttrs (cfg.database.options != null) {
          LD_DB_OPTIONS = cfg.database.options;
        };
      environmentFiles = cfg.environmentFiles;
      autoStart = true;
    };

    virtualisation.oci-containers.backend = "podman";

    systemd.tmpfiles.rules =
      [
        "d ${cfg.dataDir} 0755 root root -"
      ]
      ++ optionals cfg.enableBackups [
        "d ${cfg.backupDir} 0755 root root -"
      ];

    systemd.services.linkding-backup = mkIf cfg.enableBackups {
      description = "Backup linkding data";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.rsync}/bin/rsync -av ${cfg.dataDir}/ ${cfg.backupDir}/";
      };
    };

    systemd.timers.linkding-backup = mkIf cfg.enableBackups {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    systemd.timers.podman-auto-update = mkIf cfg.enableAutoUpdate {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
    };

    systemd.services.podman-auto-update = mkIf cfg.enableAutoUpdate {
      script = ''
        ${pkgs.podman}/bin/podman auto-update
      '';
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
