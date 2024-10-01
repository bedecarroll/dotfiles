{ pkgs, lib, config, ... }: {

  options = {
    editors.enable = lib.mkEnableOption "editors etc";
  };

  config = lib.mkIf config.editors.enable {
    home.packages = with pkgs; [ nano glow ];
  };
}

