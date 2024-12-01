{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    # Waybar etc fonts
    noto-fonts
    noto-fonts-cjk
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
}
