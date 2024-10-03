{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    data.enable = lib.mkEnableOption "data analysis pkgs";
  };

  config = lib.mkIf config.data.enable {
    home.packages = with pkgs; [
      fx
      gron
      miller
      #visidata # this thing always breaks
      xsv
    ];
  };
}
