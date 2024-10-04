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
    security.onepw.enable = mkEnableOption "1password";
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
    (mkIf cfg.onepw.enable { home.packages = with pkgs; [ _1password-gui ]; })
  ];
}
