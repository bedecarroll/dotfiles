{ config, pkgs, ... }:

{
  config = {
    # Linux perf debugging tools
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

