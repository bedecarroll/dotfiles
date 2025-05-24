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

      # A lot of the settings from
      # https://github.com/catppuccin/hyprlock/blob/main/hyprlock.conf
      settings = {
        general = {
          hide_cursor = true;
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
            size = "300, 60";
            outline_thickness = 4;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgb(cba6f7)";
            inner_color = "rgb(313244)";
            font_color = "rgb(cdd6f4)";
            fade_on_empty = false;
            placeholder_text = ''<span foreground="##cdd6f4"><i>󰌾 Logged in as </i><span foreground="##cba6f7">$USER</span></span>'';
            hide_input = false;
            check_color = "rgb(cba6f7)";
            fail_color = "rgb(f38ba8)";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            capslock_color = "rgb(f9e2af)";
            position = "0, -47";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          {
            text = "$TIME";
            color = "rgb(cdd6f4)";
            font_size = 90;
            font_family = "JetBrainsMono Nerd Font";
            position = "-30, 0";
            halign = "right";
            valign = "top";
          }

          {
            text = ''cmd[update:43200000] date +"%A, %d %B %Y"'';
            color = "rgb(cdd6f4)";
            font_size = 25;
            font_family = "JetBrainsMono Nerd Font";
            position = "-30, -150";
            halign = "right";
            valign = "top";
          }
        ];
      };
    };
  };
}
