{ lib, config, ... }:
with lib;
let
  cfg = config.keyboard;
in
{
  options = {
    keyboard.enable = mkEnableOption "X11/console keyboard settings";
  };
  config = mkIf cfg.enable {
    services.xserver.xkb.layout = "us";
    services.xserver.xkb.options = "caps:escape";
    console.useXkbConfig = true;
  };
}
