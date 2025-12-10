{
  lib,
  config,
  pkgs,
  ...
}:
{

  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    # Needed but config is in home-manager
    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.common = {
        default = [ "hyprland" "gtk" ];
      };
    };
  };
}
