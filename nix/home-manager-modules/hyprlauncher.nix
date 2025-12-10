{
  lib,
  config,
  pkgs,
  pkgs-unstable ? pkgs,
  ...
}:
with lib;
let
  cfg = config.hyprlauncher;
  hyprlauncherPkg = pkgs.hyprlauncher or pkgs-unstable.hyprlauncher;
in
{
  options = {
    hyprlauncher.enable = mkEnableOption "Hyprlauncher app launcher";
  };

  config = mkIf cfg.enable {
    home.packages = [ hyprlauncherPkg ];

    # Hyprlauncher configuration (hyprlang syntax)
    xdg.configFile."hypr/hyprlauncher.conf".text = ''
      general {
        grab_focus = true
      }

      cache {
        enabled = true
      }

      finders {
        default_finder = desktop
        desktop_prefix =
        unicode_prefix = .
        math_prefix = =
        font_prefix = '
        desktop_launch_prefix =
        desktop_icons = true
      }

      ui {
        window_size = 400 260
      }
    '';
  };
}
