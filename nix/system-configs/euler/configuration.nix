{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Import all our standardized modules
  imports = [
    ../../nixos-modules
    # SOPS module for encrypted secrets
    inputs.sops-nix.nixosModules.sops
  ];

  # Running inside a Proxmox QEMU guest
  services.qemuGuest.enable = true;

  # File systems configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Boot loader configuration
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  # Ensure filesystem modules are available in initrd
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # VM-specific performance optimizations
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Disable unnecessary services for headless VM
  systemd.services.systemd-udev-settle.enable = false;
  
  # Configure SOPS-nix to generate age key automatically for new VMs
  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  
  # Ensure the sops-nix directory persists
  systemd.tmpfiles.rules = [
    "d /var/lib/sops-nix 0755 root root -"
  ];

  # Enable modules for headless web server
  fonts.enable = true;
  hardware.enable = true;
  keyboard.enable = true;
  locale.enable = true;
  minimumPackages.enable = true;
  monitoring.enable = true;
  networking.enable = true;
  nixConfig.enable = true;
  ntp.enable = true;
  securityDefaults.enable = true;
  usersConfig.enable = true;
  # Enable container support for Docker/Podman
  containerSupport.enable = true;
  # Enable Tailscale for VM connectivity
  vpn.enable = true;
  # Enable Linkding bookmark manager service
  linkding.enable = true;
  # Configure Linkding service
  linkding.environmentFiles = [ config.sops.secrets.linkding_env.path ];
  # Configure CSRF trusted origins for reverse proxy
  linkding.csrfTrustedOrigins = [ "https://linkding.bede.ai" ];
  # Enable Golink URL shortener service
  golink.enable = true;
  golink.environmentFiles = [ config.sops.secrets.golink_env.path ];

  # SOPS secrets configuration
  sops.secrets = {
    # Shared dummy secret to ensure age key generation on first deploy
    dummy = {
      sopsFile = ../../shared-secrets.sops.yaml;
    };
    # Shared Tailscale auth key
    tailscale_authkey = {
      sopsFile = ../../shared-secrets.sops.yaml;
    };
    # Tailscale auth key in environment format for golink
    golink_env = {
      sopsFile = ../../shared-secrets.sops.yaml;
    };
    # Linkding environment variables
    linkding_env = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
  # Tailscale auth key configuration
  services.tailscale.authKeyFile = config.sops.secrets.tailscale_authkey.path;

  # Ensure SSH is available for remote admin with hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };
  
  # Add your SSH public key for remote access
  users.users.bc.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHnBzfvZNjJja79pwp/ZmiGdoN8gzzcMPyu8zlbkVavGAAAABHNzaDo="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc7XLm936xcCFngohG73fs9T5lfikrHzYHErvGF+mna"
  ];


  # Host-specific settings
  networking.hostName = "euler";
  time.timeZone = "UTC";
  
  # Ensure DHCP is enabled for automatic network configuration
  networking.useDHCP = lib.mkDefault true;

  # Automatic system updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "04:00";
    flake = "github:bedecarroll/dotfiles#euler";
  };

  # NixOS release this config is compatible with
  system.stateVersion = "24.05";
}
