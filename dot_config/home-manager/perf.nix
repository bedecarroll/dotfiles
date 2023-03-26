{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      htop
      bottom
      ctop
      hyperfine
      sysstat
      iotop
    ];
  };
}

