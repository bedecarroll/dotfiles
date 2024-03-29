{ config, pkgs, ... }:

{
  config = {
    # Everything else
    home.packages = with pkgs; [
      coreutils
      moreutils
      bat
      ripgrep
      lsd
      fd
      # JSON tools
      jc
      jq
      procs
      lnav
      grex
      entr
      bc
      lshw
      unzip
      tree
      sqlite-utils
      # Provides lstopo for hw diagrams
      hwloc
      # PDF utils
      poppler_utils
      pdfgrep
      dotenv-linter
      # Git tools
      pre-commit
      lazygit
    ];
  };
}

