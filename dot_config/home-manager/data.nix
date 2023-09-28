{ config, pkgs, ... }:

{
  config = {
    # Packages for data manipulation
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
