{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.mako;
in
{
  options = {
    mako.enable = mkEnableOption "Mako notifications";
  };
  config = mkIf cfg.enable {
    services.mako = {
      enable = true;
      settings = {
        background-color = "#1e1e2e";
        text-color = "#cdd6f4";
        border-color = "#cba6f7";
        progress-color = "over #313244";

        "urgency=high" = {
          border-color = "#fab387";
        };
      };
    };
  };
}
