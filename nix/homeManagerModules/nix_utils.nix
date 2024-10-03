{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    nix_utils.enable = lib.mkEnableOption "useful nix stuff";
  };

  config = lib.mkIf config.nix_utils.enable {
    home.packages = with pkgs; [
      nh
      nvd
      nix-output-monitor
      nixfmt-rfc-style
      nixpkgs-fmt
    ];
  };
}
