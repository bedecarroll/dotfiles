{ lib, config, ... }:
with lib;
let
  cfg = config.hardware;
in
{

  options = {
    hardware.enable = mkEnableOption "hardware management";
  };

  config = mkIf cfg.enable { services.fwupd.enable = true; };
}
