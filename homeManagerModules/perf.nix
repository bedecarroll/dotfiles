{ pkgs, lib, config, ... }: {

  options = {
    perf.enable = lib.mkEnableOption "linux perf and debug tools";
  };

  config = lib.mkIf config.perf.enable {
    home.packages = with pkgs; [ htop bottom ctop hyperfine sysstat iotop ];
  };
}

