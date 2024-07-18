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
      httpie
      tcpdump
      cidr # Different sipcalc
      ngrep
      # Developer reverse tunnel
      ngrok
    ];
  };
}

