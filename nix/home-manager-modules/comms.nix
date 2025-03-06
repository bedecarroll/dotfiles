{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.comms;
in
{

  options = {
    comms.enable = mkEnableOption "communications pkgs";
    comms.discord.enable = mkEnableOption "discord";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        # neomutt # notmuch is broken
        weechat
      ];
    })
    (mkIf cfg.discord.enable { home.packages = with pkgs; [ discord ]; })
  ];
}
