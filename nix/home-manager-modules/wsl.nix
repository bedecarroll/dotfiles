{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.wsl;
in
{

  options = {
    wsl.enable = mkEnableOption "pkgs need on wsl installs";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ topgrade ]; };
}
