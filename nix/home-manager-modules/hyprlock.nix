{ lib, config, ... }:
with lib;
let
  cfg = config.hyprlock;
in
{
  options = {
    hyprlock.enable = mkEnableOption "Hyprlock config";
  };

  config = mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          no_fade_in = true;
          no_fade_out = true;
          hide_cursor = false;
          grace = 0;
          disable_loading_bar = true;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 2;
            contrast = 1;
            brightness = 0.5;
            vibrancy = 0.2;
            vibrancy_darkness = 0.2;
          }
        ];

        input-field = [
          {
            size = "250, 60";
            outline_thickness = 2;
            dots_size = 0.2; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.35; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(0, 0, 0, 0.2)";
            font_color = "$foreground";
            fade_on_empty = false;
            rounding = -1;
            check_color = "rgb(204, 136, 34)";
            placeholder_text = "<i><span foreground=\"##cdd6f4\">Input Password...</span></i>";
            hide_input = false;
            position = "0, -200";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          {
            text = "cmd[update:1000] echo \"$(date +\"%A, %B %d\")\"";
            color = "rgba(242, 243, 244, 0.75)";
            font_size = 22;
            font_family = "JetBrains Mono";
            position = "0, 300";
            halign = "center";
            valign = "center";
          }

          {
            text = "cmd[update:1000] echo \"$(date +\"%-I:%M\")\"";
            color = "rgba(242, 243, 244, 0.75)";
            font_size = 95;
            font_family = "JetBrains Mono Extrabold";
            position = "0, 200";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
