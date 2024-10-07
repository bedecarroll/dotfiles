{ ... }:
{
  users.users.bc = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "tss" # tss group has access to TPM devices
      "wheel"
    ];
  };
}
