{ pkgs, lib, ... }: {
  imports = [
    ./hyprland.nix
  ];

  hyprland.enable = lib.mkDefault true;
}
