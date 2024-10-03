{ pkgs, lib, ... }:
{
  imports = [ ./neovim.nix ];

  neovim.enable = lib.mkDefault true;
}
