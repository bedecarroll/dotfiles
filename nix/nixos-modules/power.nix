{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.power;
in
{
  options = {
    power.enable = mkEnableOption "power management and tools";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      acpi
      brightnessctl
      cpupower-gui
    ];
    powerManagement.enable = true;
    powerManagement.cpuFreqGovernor = "performance";
    services.thermald.enable = true;
    services.tlp.enable = true;
    services.tlp.settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
      # Optional helps save long term battery health
      START_CHARGE_THRESH_BAT0 = 40; # start charging at 40%
      STOP_CHARGE_THRESH_BAT0 = 80; # stop charging at 80%
    };
  };
}
