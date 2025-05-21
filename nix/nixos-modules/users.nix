{ lib, config, ... }:
with lib;
let
  cfg = config.usersConfig;
in
{
  options = {
    usersConfig.enable = mkEnableOption "local user accounts";
  };
  config = mkIf cfg.enable {
    users.users.bc = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "tss" # tss group has access to TPM devices
        "wheel"
      ];
    };
  };
}
