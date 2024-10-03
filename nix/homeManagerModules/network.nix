{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    network.enable = lib.mkEnableOption "network troubleshooting and monitoring";
  };

  config = lib.mkIf config.network.enable {
    home.packages = with pkgs; [
      # bandwhich # broken
      curl
      gping
      httpie
      mtr
      netperf
      ngrep
      ngrok # Developer reverse tunnel
      sipcalc
      tcpdump
      wget
    ];
  };
}
