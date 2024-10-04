{ lib, config, ... }:
with lib;
let
  cfg = config.golang;
in
{

  options = {
    golang.enable = mkEnableOption "golang";
  };

  config = mkIf cfg.enable { programs.go.enable = true; };
}
