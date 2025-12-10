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
      noto-fonts-color-emoji
      liberation_ttf
      nerd-fonts.jetbrains-mono
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
