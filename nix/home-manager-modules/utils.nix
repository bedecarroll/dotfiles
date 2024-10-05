{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.utils;
in
{

  options = {
    utils.enable = mkEnableOption "the everything else list";
  };

  config = mkIf cfg.enable {
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
