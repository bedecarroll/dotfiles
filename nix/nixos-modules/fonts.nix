{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fonts;
in
{
  options = {
    fonts.enable = mkEnableOption "font packages";
  };
  config = mkIf cfg.enable {
    fonts.packages = with pkgs; [
      # Waybar etc fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      nerdfonts
      roboto-mono
      font-awesome
      # Coding/terminal fonts
      fira-code
      fira-code-symbols
      comic-mono
      jetbrains-mono
    ];
  };
}
