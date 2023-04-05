{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      # Pyarrow is now needed and isn't installing
      #visidata
      fx
      xsv
      miller
      gron
    ];
  };
}
