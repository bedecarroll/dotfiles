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
  hardware.enable = true;
  hyprland.enable = true;
  usb.enable = true;
  video.enable = true;
  vpn.enable = true;

  # https://discourse.nixos.org/t/full-disk-encryption-tpm2/29454
  # After setting up the disks we can get the TPM to unlock the disk
  # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0 /dev/nvme0n1p2
  # We use pcrs=0 and not pcrs=0+7 because we don't have secure boot

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # lower this to 10 when stable
  boot.loader.systemd-boot.configurationLimit = 20;

  networking.hostName = "kepler"; # Define your hostname.

  time.timeZone = "America/Los_Angeles";

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  system.stateVersion = "24.05"; # Did you read the comment?
}
