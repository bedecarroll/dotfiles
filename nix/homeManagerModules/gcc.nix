{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.gcc;
in
{

  options = {
    gcc.enable = mkEnableOption "gcc compiler";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ gcc14 ]; };
}
