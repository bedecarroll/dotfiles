{ lib, config, ... }:
with lib;
let
  cfg = config.bluetooth;
in
{

  options = {
    bluetooth.enable = mkEnableOption "Bluetooth settings";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
