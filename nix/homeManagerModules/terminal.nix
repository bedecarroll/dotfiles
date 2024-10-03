{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    terminal.enable = lib.mkEnableOption "std terminals";
  };

  config = lib.mkIf config.terminal.enable {
    home.packages = with pkgs; [
      wezterm
      alacritty
      kitty
    ];
  };
}
