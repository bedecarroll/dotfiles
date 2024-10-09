{ lib, config, ... }:
{

  options = {
    hyprland.enable = lib.mkEnableOption "enables hyprland";
  };

  config = lib.mkIf config.hyprland.enable {
    # Needed but config is in home-manager
    programs.hyprland.enable = true;
  };
}
