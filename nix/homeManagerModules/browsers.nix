{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.browsers;
in
{

  options = {
    browsers.enable = mkEnableOption "web browsers";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lynx
      firefox
    ];
  };
}
