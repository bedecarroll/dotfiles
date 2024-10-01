{ pkgs, lib, config, ... }: {

  options = {
    template1.enable = lib.mkEnableOption "enables template1";
  };

  config = lib.mkIf config.template1.enable {
    
  };

}
