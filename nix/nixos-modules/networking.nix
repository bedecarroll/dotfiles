{ ... }:
{
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  programs.mtr.enable = true; # enable setcap wrapper so we don't need to sudo
}
