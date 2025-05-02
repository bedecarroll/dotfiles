{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.security;
in
{

  options = {
    security.enable = mkEnableOption "security tooling";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        age
        cacert
        sops
        yubikey-manager
        yubikey-personalization
      ];
    })
  ];
}
