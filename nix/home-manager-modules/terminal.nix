{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.terminal;
in
{

  options = {
    terminal.enable = lib.mkEnableOption "std terminals";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      wezterm
      alacritty
      kitty
    ];
  };
}
