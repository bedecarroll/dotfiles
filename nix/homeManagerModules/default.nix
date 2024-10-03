{ pkgs, lib, ... }:
{
  imports = [
    ./base.nix
    ./data.nix
    ./editors
    ./help.nix
    ./iac.nix
    ./network.nix
    ./nix_utils.nix
    ./perf.nix
    ./personal.nix
    ./python.nix
    ./rust.nix
    ./security.nix
    ./space.nix
    ./terminal.nix
    ./utils.nix
    ./wsl.nix
  ];

  base.enable = lib.mkDefault true;
  data.enable = lib.mkDefault true;
  help.enable = lib.mkDefault true;
  iac.enable = lib.mkDefault true;
  network.enable = lib.mkDefault true;
  nix_utils.enable = lib.mkDefault true;
  perf.enable = lib.mkDefault true;
  personal.enable = lib.mkDefault false;
  python.enable = lib.mkDefault true;
  rust.enable = lib.mkDefault true;
  security.enable = lib.mkDefault true;
  space.enable = lib.mkDefault true;
  terminal.enable = lib.mkDefault true;
  utils.enable = lib.mkDefault true;
  wsl.enable = lib.mkDefault false;
}
