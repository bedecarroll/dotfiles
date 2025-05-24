{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.data;
in
{

  options = {
    data.enable = mkEnableOption "data analysis pkgs";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fx
      gron
      miller
      #visidata # this thing always breaks
      xan
    ];
  };
}
