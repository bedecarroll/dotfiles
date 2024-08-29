{ pkgs, ... }:

{
  config = {
    # Everything else
    home.packages = with pkgs; [
      coreutils
      moreutils
      fd
      # JSON tools
      jc
      procs
      lnav
      grex
      entr
      watchexec
      bc
      lshw
      unzip
      tree
      sqlite-utils
      # Provides lstopo for hw diagrams
      #hwloc  # Broken bash completions
      # PDF utils
      poppler_utils
      pdfgrep
      dotenv-linter
      # Git tools
      lazygit
      direnv # .envrc files to autoload
    ];
  };
}

