{ pkgs, ... }:

{
  config = {
    # Packages for data manipulation
    home.packages = with pkgs; [
      #visidata
      fx
      xsv
      miller
      gron
    ];
  };
}
