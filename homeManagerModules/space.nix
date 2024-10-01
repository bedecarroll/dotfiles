{ pkgs, lib, config, ... }: {

  options = {
    space.enable = lib.mkEnableOption "disk space utils";
  };

  config = lib.mkIf config.space.enable {
    home.packages = with pkgs; [ du-dust duf broot btdu ];
  };
}
