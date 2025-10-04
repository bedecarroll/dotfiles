{ ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../nixos-modules
  ];

  # nixos-modules settings
  audio.enable = true;
  bluetooth.enable = true;
  fonts.enable = true;
  greetd.enable = true;
  hardware.enable = true;
  hyprland.enable = true;
  keyboard.enable = true;
  locale.enable = true;
  minimumPackages.enable = true;
  monitoring.enable = true;
  networking.enable = true;
  nixConfig.enable = true;
  ntp.enable = true;
  onepw.enable = true;
  power.enable = true;
  securityDefaults.enable = true;
  usb.enable = true;
  usersConfig.enable = true;
  video.enable = true;
  vpn.enable = true;

  services.logind = {
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  # Disable all touchscreens system-wide via libinput
  # This udev rule sets LIBINPUT_IGNORE_DEVICE for touchscreen-class devices
  services.udev.extraRules = ''
    ACTION=="add|change", ENV{ID_INPUT_TOUCHSCREEN}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
  '';

  # https://discourse.nixos.org/t/full-disk-encryption-tpm2/29454
  # After setting up the disks we can get the TPM to unlock the disk
  # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0 /dev/nvme0n1p2
  # We use pcrs=0 and not pcrs=0+7 because we don't have secure boot

  # This is needed to auto-unlock LUKS with TPM 2 - https://discourse.nixos.org/t/full-disk-encryption-tpm2/29454/2
  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  systemd = {
    coredump.enable = true;
  };

  networking.hostName = "kepler"; # Define your hostname.

  time.timeZone = "America/Los_Angeles";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  system.stateVersion = "24.05"; # Did you read the comment?
}
