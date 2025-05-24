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
      backgroundColor = "#1e1e2e";
      textColor = "#cdd6f4";
      borderColor = "#cba6f7";
      progressColor = "over #313244";
      extraConfig = ''
        [urgency=high]
        border-color=#fab387
      '';
    };
  };
}
