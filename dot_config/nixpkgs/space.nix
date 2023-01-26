{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      htop
      bottom
      ctop
      entr
      du-dust
      duf
      broot
      btdu
    ];
  };
}
