{ lib, config, ... }:
with lib;
let
  cfg = config.locale;
in
{
  options = {
    locale.enable = mkEnableOption "locale settings";
  };
  config = mkIf cfg.enable {
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
