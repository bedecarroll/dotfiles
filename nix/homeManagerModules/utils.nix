{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    utils.enable = lib.mkEnableOption "the everything else list";
  };

  config = lib.mkIf config.utils.enable {
    home.packages = with pkgs; [
      bc
      coreutils
      direnv # .envrc files to autoload
      dotenv-linter
      entr
      fd
      grex
      #hwloc  # Broken bash completions
      jc
      lazygit
      lnav
      lshw
      moreutils
      pdfgrep
      poppler_utils
      procs
      # Provides lstopo for hw diagrams
      sqlite-utils
      tree
      unzip
      watchexec
    ];
  };
}
