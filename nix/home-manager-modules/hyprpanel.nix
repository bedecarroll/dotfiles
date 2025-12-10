{
  lib,
  config,
  pkgs,
  pkgs-unstable ? pkgs,
  ...
}:
with lib;
let
  cfg = config.hyprpanel;
  hyprpanelPkg = pkgs.hyprpanel or pkgs-unstable.hyprpanel;
  layoutCommon = {
    left = [
      "dashboard"
      "workspaces"
      "windowtitle"
      "ram"
      "cpu"
      "hypridle"
      "volume"
    ];
    middle = [ ];
    right = [
      "network"
      "notifications"
      "power"
      "battery"
      "systray"
      "clock"
    ];
  };
  hyprpanelConfig = {
    bar = {
      layouts = {
        "0" = layoutCommon;
        "1" = layoutCommon;
        "2" = layoutCommon;
      };
      workspaces.workspaces = 10;
      launcher = {
        icon = "";
        autoDetectIcon = false;
        middleClick = "hyprlauncher";
      };
      windowtitle = {
        truncation = true;
        truncation_size = 22;
      };
      volume.rightClick = "sleep 0.1 && pavucontrol";
      clock = {
        showIcon = false;
        format = "%I:%M %p";
      };
      customModules = {
        ram.labelType = "percentage";
        cpu.label = true;
        hypridle.label = true;
        power = {
          icon = "";
          showLabel = false;
          leftClick = "hyprctl dispatch exit";
        };
      };
    };
  };
in
{
  options = {
    hyprpanel.enable = mkEnableOption "Hyprpanel status bar";
  };

  config = mkIf cfg.enable {
    home.packages = [ hyprpanelPkg ];

    xdg.configFile."hyprpanel/config.json".text = builtins.toJSON hyprpanelConfig;
  };
}
