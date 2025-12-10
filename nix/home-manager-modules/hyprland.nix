{
  pkgs,
  pkgs-unstable ? pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hyprland;
  hyprlauncherPkg = pkgs.hyprlauncher or pkgs-unstable.hyprlauncher;
  hyprpanelPkg = pkgs.hyprpanel or pkgs-unstable.hyprpanel;
in
{

  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprlauncher.nix
    ./hyprpanel.nix
    ./mako.nix
  ];

  options = {
    hyprland.enable = mkEnableOption "Hyprland config";
  };

  config = mkIf cfg.enable {
    hypridle.enable = true;
    hyprlock.enable = true;
    hyprpaper.enable = true;
    hyprlauncher.enable = true;
    mako.enable = true;
    hyprpanel.enable = true;

    home.sessionVariables.NIXOS_OZONE_WL = "1";

    home.packages = with pkgs; [
      cliphist
      grim
      libnotify
      lxqt.lxqt-policykit
      networkmanagerapplet
      wl-clipboard
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      plugins = [
        pkgs.hyprlandPlugins.borders-plus-plus
        pkgs.hyprlandPlugins.hyprbars
        pkgs.hyprlandPlugins.hyprexpo
      ];

      settings = {
        # https://wiki.hyprland.org/Configuring/Variables/#variable-types
        "$mod" = "SUPER";
        "$terminal" = "${lib.getExe pkgs.wezterm}";
        "$browser" = "${lib.getExe pkgs.brave}";
        "$launcher" = "${lib.getExe hyprlauncherPkg}";
        "$grimshot" = "${lib.getExe pkgs.grim}";
        "$screenshot-path" = "/home/bc/Pictures/screenshots";

        # https://wiki.hyprland.org/Configuring/Keywords/#executing
        exec-once = [
          "${lib.getExe pkgs.mako} &"
          "${lib.getExe hyprpanelPkg} &"
          "${lib.getExe pkgs.lxqt.lxqt-policykit} &"
          "${pkgs.networkmanagerapplet}/nm-applet &"
          "[workspace 1 silent] $terminal"
          "[workspace 2 silent] $browser"
        ];

        # https://wiki.hyprland.org/Configuring/Monitors/
        monitor = [ ",preferred,auto,1" ];

        # https://wiki.hyprland.org/Configuring/Variables/#general
        general = {
          gaps_in = 2;
          gaps_out = 4;
          border_size = 0;
          resize_on_border = true;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
        };

        # https://wiki.hyprland.org/Configuring/Variables/#input
        input = {
          kb_layout = "us";
          kb_options = "caps:escape";
          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
          follow_mouse = 1;

          # https://wiki.hyprland.org/Configuring/Variables/#touchpad
          touchpad = {
            natural_scroll = true;
          };
        };

        # https://wiki.hyprland.org/Configuring/Variables/#decoration
        decoration = {
          rounding = 2;

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur = {
            enabled = true;
            size = 3;
            passes = 3;
            # new_optimizations = 3;
          };
        };

        # https://wiki.hyprland.org/Configuring/Animations/
        animations = {
          enabled = true;

          bezier = [
            "fluent_decel, 0, 0.2, 0.4, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutCubic, 0.33, 1, 0.68, 1"
            "easeinoutsine, 0.37, 0, 0.63, 1"
          ];
          animation = [
            # Windows
            "windowsIn, 1, 4, easeOutCubic, popin 20%" # window open
            "windowsOut, 1, 4, fluent_decel, popin 80%" # window close.
            "windowsMove, 1, 2, easeinoutsine, slide" # everything in between, moving, dragging, resizing.

            # Fade
            "fadeIn, 1, 3, easeOutCubic" # fade in (open) -> layers and windows
            "fadeOut, 1, 2, easeOutCubic" # fade out (close) -> layers and windows
            "fadeSwitch, 0, 1, easeOutCirc" # fade on changing activewindow and its opacity
            "fadeShadow, 1, 10, easeOutCirc" # fade on changing activewindow for shadows
            "fadeDim, 1, 4, fluent_decel" # the easing of the dimming of inactive windows
            "border, 1, 2.7, easeOutCirc" # for animating the border's color switch speed
            "borderangle, 1, 30, fluent_decel, once" # for animating the border's gradient angle - styles: once (default), loop
            "workspaces, 1, 5, easeOutCubic, fade" # styles: slide, slidevert, fade, slidefade, slidefadevert
          ];
        };

        # https://wiki.hyprland.org/Configuring/Dwindle-Layout/
        general.layout = "dwindle";
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        bind = [
          "$mod, F1, exec, show-keybinds"

          # App start
          "$mod, T, exec, $terminal"
          "$mod, B, exec, $browser"
          "$mod, SPACE, exec, $launcher"

          "$mod, Q, killactive,"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"
          "$mod, O, exec, toggleopaque,"

          # Move focus with mod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Switch workspaces with mod + [0-9]
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move active window to a workspace with mod + SHIFT + [0-9]
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Screenshot
          # All visible outputs
          ", Print, exec, $grimshot --notify save screen $($screenshot-path/$(date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')"
          # Manually select a region
          "SHIFT, Print, exec, $grimshot --notify save area $($screenshot-path/$(date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')"
          # Currently active window
          "ALT, Print, exec, $grimshot --notify save active $($screenshot-path/$(date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')"
          # Manually select a window
          "SHIFT_ALT, Print, exec, $grimshot --notify save window $($screenshot-path/$(date +'screenshot_%Y-%m-%d-%H%M%S.%3N.png')"
          "CTRL, Print, exec, $grimshot --notify copy screen"
          "CTRL_SHIFT, Print, exec, $grimshot --notify copy area"
          "CTRL_ALT, Print, exec, $grimshot --notify copy active"
          "CTRL_SHIFT_ALT, Print, exec, $grimshot --notify copy window"
        ];

        bindm = [
          # Move/resize windows
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        plugin = {
          hyprbars = {
            bar_height = 30;
            bar_color = "rgb(1e1e1e)";
            col.text = "rgb(cdd6f4)";
            bar_text_size = 8;
            bar_text_font = "Fira Code Symbol";
            bar_button_padding = 12;
            bar_padding = 10;
            bar_precedence_over_border = true;
            hyprbars-button = [
              "rgb(f38ba8), 20, , hyprctl dispatch killactive"
              "rgb(f9e2af), 20, , hyprctl dispatch fullscreen 2"
              "rgb(74c7ec), 20, , hyprctl dispatch togglefloating"
            ];
          };
        };

        # Disable windows forcing maximize
        windowrulev2 = "suppressevent maximize, class:.*";
      };
    };
  };
}
