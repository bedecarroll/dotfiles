{ config, pkgs, ... }:

{
  config = {
    # Network troubleshooting and monitoring
    home.packages = with pkgs; [
      gping
      mtr
      bandwhich
      netperf
      sipcalc
      wget
      curl
      tcpdump
      ngrep
      # Developer reverse tunnel
      ngrok
    ];
  };
}

