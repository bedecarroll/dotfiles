{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.monitoring;
in
{

  options = {
    monitoring.enable = mkEnableOption "system monitoring";
  };

  config = mkIf cfg.enable {
    programs.atop = {
      enable = true;
      setuidWrapper.enable = true;
    };
  };
}
