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
      fd
      hwloc # lstopo for hw diagrams
      jc
      lnav
      lshw
      moreutils
      neofetch
      pdfgrep
      poppler-utils
      procs # ps replacement
      sqlite-utils
      tree
      unzip
      # Annoying stty bug, disable
      # (lib.hiPrio uutils-coreutils-noprefix)
    ];
  };
}
