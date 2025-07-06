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

  # File systems configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Boot loader configuration
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

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
  securityDefaults.enable = true;
  usersConfig.enable = true;
  # Enable Tailscale for VPN connectivity
  vpn.enable = true;
  # Enable reverse proxy with Tailscale integration
  reverseProxy.enable = true;
  # Enable Eternal Terminal for persistent SSH sessions
  services.eternal-terminal.enable = true;

  # SOPS secrets configuration (disabled until encrypted)
  # sops.secrets = {
  #   # Shared Tailscale auth key
  #   tailscale_authkey = {
  #     sopsFile = ../../shared-secrets.sops.yaml;
  #   };
  # };

  # SSH configuration with hardening
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

  # Automatic system updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "04:00";
    flake = "github:bedecarroll/dotfiles#pascal";
  };

  # Host-specific settings
  networking.hostName = "pascal";
  time.timeZone = "UTC";

  # Ensure DHCP is enabled for automatic network configuration
  networking.useDHCP = lib.mkDefault true;

  # Open SSH port (HTTP/HTTPS handled by reverse proxy module)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # NixOS release this config is compatible with
  system.stateVersion = "24.05";
}