{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.help;
in
{

  options = {
    help.enable = mkEnableOption "help docs and cheatsheets";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      man
      cheat
      tealdeer
      navi
    ];
  };
}
