{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.editors;
in
{

  options = {
    editors.enable = mkEnableOption "editors etc";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nano
      glow
      tree-sitter
      (pkgs-unstable.neovim.override { extraLuaPackages = ps: with ps; [ jsregexp ]; })
    ];
  };
}
