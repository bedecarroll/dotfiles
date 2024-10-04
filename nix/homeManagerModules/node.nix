{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.node;
in
{

  options = {
    node.enable = mkEnableOption "node/js pkgs";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_22
      bun
    ];
  };
}
