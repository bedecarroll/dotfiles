{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      hyperfine
      sysstat
      iotop
    ];
  };
}

