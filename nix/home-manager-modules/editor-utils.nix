{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.editor-utils;
in
{

  options = {
    editor-utils.enable = mkEnableOption "editor things";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ast-grep
      glow
      tree-sitter
    ];
  };
}
