{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.iac;
in
{

  options = {
    iac.enable = mkEnableOption "common iac packages";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ansible
      #ansible-later
      ansible-lint
      awscli2
      google-cloud-sdk
      oci-cli
      opentofu
      terraformer
    ];
  };
}
