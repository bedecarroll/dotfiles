{ pkgs, ... }:

{
  config = {
    # Packages useful for dealing with nix
    home.packages = with pkgs; [ nixfmt-classic nixpkgs-fmt ];
  };
}
