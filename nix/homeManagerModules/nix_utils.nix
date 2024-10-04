{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.nix_utils;
in
{

  options = {
    nix_utils.enable = mkEnableOption "useful nix stuff";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nh
      nvd
      nix-output-monitor
      nixfmt-rfc-style
      nixpkgs-fmt
    ];
  };
}
