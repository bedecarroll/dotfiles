{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      gping
      mtr
      bandwhich
      netperf
      sipcalc
      wget
      curl
    ];
  };
}

