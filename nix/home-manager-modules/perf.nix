{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.perf;
in
{

  options = {
    perf.enable = mkEnableOption "linux perf and debug tools";
  };

  config = mkIf cfg.enable {
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
