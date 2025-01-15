{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.hmcatppuccin;
in
{

  options = {
    hmcatppuccin.enable = mkEnableOption "enable catppuccin";
  };

  config = mkIf cfg.enable {
    catppuccin.enable = true;
    catppuccin.flavor = "mocha";
  };
}
