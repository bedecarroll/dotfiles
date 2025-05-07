{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.network;
in
{

  options = {
    network.enable = mkEnableOption "network troubleshooting and monitoring";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # bandwhich # broken
      curl
      dig
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
