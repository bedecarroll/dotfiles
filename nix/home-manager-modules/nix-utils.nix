{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.nix-utils;
in
{

  options = {
    nix-utils.enable = mkEnableOption "useful nix stuff";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cachix
      nh
      nixfmt-rfc-style
      nix-output-monitor
      nixpkgs-fmt
      nvd
    ];
  };
}
