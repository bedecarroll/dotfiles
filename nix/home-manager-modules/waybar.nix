{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.waybar;
in
{
  options = {
    waybar.enable = mkEnableOption "Waybar status bar";
  };
  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          tray-position = "right";
          modules-left = [
            "sway/workspaces"
            "sway/mode"
          ];
          modules-center = [ "clock" ];
          modules-right = [
            "cpu"
            "memory"
            "network"
            "battery"
            "tray"
          ];
        };
      };

      style = ''
        * {
          font-family: "JetBrains Mono", monospace;
          font-size: 10pt;
        }
        #workspaces, #mode, #clock, #cpu, #memory, #network, #battery, #tray {
          padding: 0 8px;
        }
        window .background {
          background-color: #2E3440;
          color: #D8DEE9;
          border-radius: 4px;
          margin: 2px;
        }
      '';
    };
  };
}
