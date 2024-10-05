{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    comic-mono
  ];
}
