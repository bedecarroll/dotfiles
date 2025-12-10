{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.storage;
in
{

  options = {
    storage.enable = mkEnableOption "storage utils";
    storage.dropbox.enable = mkEnableOption "dropbox";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        dust
        duf
        broot
        btdu
      ];
    })
    (mkIf cfg.dropbox.enable { home.packages = with pkgs; [ dropbox ]; })
  ];
}
