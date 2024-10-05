{ lib, ... }:
with lib;
{
  imports = [
    ./ai.nix
    ./base.nix
    ./browsers.nix
    ./comms.nix
    ./data.nix
    ./editors.nix
    ./editor-utils.nix
    ./gcc.nix
    ./golang.nix
    ./help.nix
    ./iac.nix
    ./network.nix
    ./nix-utils.nix
    ./node.nix
    ./perf.nix
    ./python.nix
    ./rust.nix
    ./security.nix
    ./storage.nix
    ./terminal.nix
    ./utils.nix
    ./video.nix
    ./wsl.nix
  ];

  base.enable = mkDefault true;
  data.enable = mkDefault true;
  editors.enable = mkDefault true;
  editor-utils.enable = mkDefault true;
  gcc.enable = mkDefault true;
  golang.enable = mkDefault true;
  help.enable = mkDefault true;
  iac.enable = mkDefault true;
  network.enable = mkDefault true;
  nix-utils.enable = mkDefault true;
  node.enable = mkDefault true;
  perf.enable = mkDefault true;
  python.enable = mkDefault true;
  rust.enable = mkDefault true;
  security.enable = mkDefault true;
  storage.enable = mkDefault true;
  terminal.enable = mkDefault true;
  utils.enable = mkDefault true;
}
