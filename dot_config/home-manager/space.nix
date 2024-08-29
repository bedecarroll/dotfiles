{ pkgs, ... }:

{
  config = {
    # Disk/space utils
    home.packages = with pkgs; [ du-dust duf broot btdu ];
  };
}
