{ lib, config, ... }:
with lib;
let
  cfg = config.containerSupport;
in
{
  imports = [
    ./golink.nix
    ./linkding.nix
  ];

  options = {
    containerSupport.enable = mkEnableOption "Enable container support";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Docker
    virtualisation = {
      podman = {
        enable = true;
        # Create the default bridge network for podman
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}
