{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hyprpaper;
  wallpapersDrv = pkgs.callPackage ../wallpapers/default.nix { };
in
{
  options = {
    hyprpaper.enable = mkEnableOption "Hyprpaper wallpaper daemon";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.hyprpaper ];

    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ "${wallpapersDrv}/line_icons.png" ];
        wallpaper = [ "random,${wallpapersDrv}" ];
      };
    };
  };
}
