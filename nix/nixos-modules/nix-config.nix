{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.nixConfig;
in
{
  options = {
    nixConfig.enable = mkEnableOption "common Nix settings (gc, flakes, etc)";
  };
  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      trusted-users = [ "@wheel" ];
    };
    programs.nh = {
      enable = true;
      flake = "/home/bc/.local/share/chezmoi";
    };
    # Needed for lua_ls in nvim etc
    programs.nix-ld.enable = true;
    # NixOS specific packages
    environment.systemPackages = with pkgs; [
      nixos-generators
      # CLI for remote deploys of NixOS machines
      deploy-rs
    ];
  };
}
