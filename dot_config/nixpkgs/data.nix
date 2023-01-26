{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      visidata
      fx
      xsv
      miller
      gron
    ];
  };
}
