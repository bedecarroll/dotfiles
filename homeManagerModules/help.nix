{ pkgs, lib, config, ... }: {

  options = {
    help.enable = lib.mkEnableOption "help docs and cheatsheets";
  };

  config = lib.mkIf config.help.enable {
    home.packages = with pkgs; [ man cheat tealdeer navi ];
  };
}

