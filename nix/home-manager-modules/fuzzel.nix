{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.fuzzel;
in
{
  options = {
    fuzzel.enable = mkEnableOption "Fuzzel app launcher";
  };
  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          terminal = "${lib.getExe pkgs.wezterm}";
        };
        colors = {
          background = "1e1e2edd";
          text = "cdd6f4ff";
          prompt = "bac2deff";
          placeholder = "7f849cff";
          input = "cdd6f4ff";
          match = "cba6f7ff";
          selection = "585b70ff";
          selection-text = "cdd6f4ff";
          selection-match = "cba6f7ff";
          counter = "7f849cff";
          border = "cba6f7ff";
        };
      };
    };
  };
}
