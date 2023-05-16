{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      coreutils
      moreutils
      bat
      ripgrep
      lsd
      fd
      jq
      procs
      lnav
      grex
      entr
      bc
      lshw
      # Provides lstopo for hw diagrams
      hwloc
    ];
  };
}

