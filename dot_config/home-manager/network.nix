{ pkgs, ... }:

{
  config = {
    # Network troubleshooting and monitoring
    home.packages = with pkgs; [
      gping
      mtr
      # bandwhich # broken
      netperf
      sipcalc
      wget
      curl
      httpie
      tcpdump
      ngrep
      # Developer reverse tunnel
      ngrok
    ];
  };
}

