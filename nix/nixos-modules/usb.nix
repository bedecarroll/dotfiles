{ lib, config, ... }:
with lib;
let
  cfg = config.usb;
in
{

  options = {
    usb.enable = mkEnableOption "USB";
  };

  config = mkIf cfg.enable {
    # Automount USB
    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
  };
}
