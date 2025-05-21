{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Import all our standardized modules
  imports = [
    ../../nixos-modules
    # SOPS module for encrypted secrets
    inputs.sops-nix.nixosModule
  ];

  # Running inside a Proxmox QEMU guest
  virtualisation.qemuGuest.enable = true;

  # Enable only the modules needed for a headless web server
  minimumPackages.enable = true;
  networking.enable = true;
  ntp.enable = true;
  nixConfig.enable = true;
  securityDefaults.enable = true;
  usersConfig.enable = true;
  # Enable Tailscale for VM connectivity; authKey comes from an encrypted SOPS file
  vpn.enable = true;
  security.sops.secrets = {
    # Decrypt Tailscale auth key stored in the companion SOPS file
    tailscale = {
      file = ./tailscale-auth.sops.yaml;
      property = "authKey";
    };
  };
  # Pass the decrypted authKey to the Tailscale service
  services.tailscale.authKey = config.security.sops.secrets.tailscale.data.authKey;

  # Ensure SSH is available for remote admin
  services.openssh.enable = true;

  # Host-specific settings
  networking.hostName = "euler";
  time.timeZone = "UTC";

  # NixOS release this config is compatible with
  system.stateVersion = "24.05";
}
