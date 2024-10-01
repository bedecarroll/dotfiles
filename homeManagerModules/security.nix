{ pkgs, lib, config, ... }: {

  options = {
    security.enable = lib.mkEnableOption "security tooling";
  };

  config = lib.mkIf config.security.enable {
    home.packages = with pkgs; [ cacert ];
  };
}

