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

  # Configure SOPS-nix to generate age key automatically for new VMs
  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Ensure the sops-nix directory persists
  systemd.tmpfiles.rules = [
    "d /var/lib/sops-nix 0755 root root -"
  ];

  # File systems configuration
  fileSystems."/" = {
    device = "/dev/mapper/ocivolume-root";
    fsType = "xfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/349C-BCCC";
    fsType = "vfat";
  };

  # Boot loader configuration
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";

  # Serial console configuration for OCI VMs
  boot.kernelParams = [ "console=ttyS0,115200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1
    terminal_input serial
    terminal_output serial
  '';

  # Critical modules for Oracle Cloud Infrastructure (OCI) VMs
  # IMPORTANT: virtio_scsi is absolutely essential for OCI boot volumes
  # Without it, /dev/sda will not appear in initrd and boot will fail
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "virtio_scsi"    # Critical: OCI uses virtio-scsi for block storage
    "dm_mod"         # Critical: Required for LVM device mapper
    "dm_snapshot"    # LVM snapshot support
    "dm_mirror"      # LVM mirror support
  ];

  # Enable LVM support in initrd for /dev/mapper/ocivolume-root
  boot.initrd.services.lvm.enable = true;
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  # Enable modules for reverse proxy server
  fonts.enable = true;
  hardware.enable = true;
  keyboard.enable = true;
  locale.enable = true;
  minimumPackages.enable = true;
  monitoring.enable = true;
  networking.enable = true;
  nixConfig.enable = true;
  ntp.enable = true;
  ntp.servers = [ "169.254.169.254" ];
  securityDefaults.enable = true;
  usersConfig.enable = true;
  # Enable Tailscale for VPN connectivity
  vpn.enable = true;
  # Enable reverse proxy with Tailscale integration
  reverseProxy.enable = true;
  # Enable Eternal Terminal for persistent SSH sessions
  services.eternal-terminal.enable = true;

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
    # Emergency user password hash
    opc_password_hash = {
      sopsFile = ./secrets.sops.yaml;
    };
  };
  # Tailscale auth key configuration
  services.tailscale.authKeyFile = config.sops.secrets.tailscale_authkey.path;

  # SSH configuration with hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password"; # Allow root with key auth only
      X11Forwarding = false;
      # Deny SSH access for emergency user - serial console only
      DenyUsers = [ "opc" ];
    };
  };

  # Add your SSH public key for remote access
  users.users.bc.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHnBzfvZNjJja79pwp/ZmiGdoN8gzzcMPyu8zlbkVavGAAAABHNzaDo="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc7XLm936xcCFngohG73fs9T5lfikrHzYHErvGF+mna"
  ];

  # Temporary: Allow root SSH access for initial deployment
  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIHnBzfvZNjJja79pwp/ZmiGdoN8gzzcMPyu8zlbkVavGAAAABHNzaDo="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc7XLm936xcCFngohG73fs9T5lfikrHzYHErvGF+mna"
  ];

  # Emergency user account for serial console access (Oracle standard)
  users.users.opc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    # Use encrypted password hash from SOPS
    hashedPasswordFile = config.sops.secrets.opc_password_hash.path;
    description = "Emergency access account for serial console";
  };

  # Configure reverse proxy virtual hosts
  reverseProxy.virtualHosts = {
    # Proxy linkding.bede.ai to euler's linkding service
    "linkding.bede.ai" = {
      upstream = "euler:9090";
    };
    # Add more services as needed
  };

  # Performance optimizations for cloud VPS
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Disable unnecessary services for headless server
  systemd.services.systemd-udev-settle.enable = false;

  # Configure logind for headless server to handle user sessions properly
  services.logind = {
    killUserProcesses = false;
    extraConfig = ''
      HandlePowerKey=ignore
      HandleLidSwitch=ignore
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      RemoveIPC=no
    '';
  };

  # Automatic system updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "04:00";
    flake = "github:bedecarroll/dotfiles#pascal";
  };

  # Host-specific settings
  networking.hostName = "pascal";
  networking.domain = "subnet07051912.vcn07051912.oraclevcn.com";
  time.timeZone = "UTC";
  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  # Ensure DHCP is enabled for automatic network configuration
  networking.useDHCP = lib.mkDefault true;

  # Open SSH port (HTTP/HTTPS handled by reverse proxy module)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      2022
    ];
  };

  # NixOS release this config is compatible with
  system.stateVersion = "24.05";
}
