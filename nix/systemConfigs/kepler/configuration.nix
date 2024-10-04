# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # lower this to 10 when stable
  boot.loader.systemd-boot.configurationLimit = 20;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  nix.settings.auto-optimise-store = true;

  networking.hostName = "kepler"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  time.timeZone = "America/Los_Angeles";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
    "ca-derivations"
  ];

  services.udev.packages = [ pkgs.yubikey-personalization ];

  # Automount USB
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd hyprland";
        user = "greeter";
      };
    };
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    comic-mono
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  programs.hyprland.enable = true;
  # Enable the X11 windowing system.
  #services.xserver.enable = true;

  nixpkgs.config.allowUnfree = true;

  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "caps:escape";
  console.useXkbConfig = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users.bc = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
    tpm2-tss
    git
    wezterm
    chezmoi
    tailscale
  ];

  programs.mtr.enable = true;

  # List services that you want to enable:
  services.tailscale.enable = true;
  services.fwupd.enable = true;

  security.sudo.wheelNeedsPassword = false;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  system.stateVersion = "24.05"; # Did you read the comment?

}
