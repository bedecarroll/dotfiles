{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  tailscaleUdpGro = pkgs.writeShellScript "tailscale-udp-gro" ''
    set -euo pipefail

    NETDEV="$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 2>/dev/null | ${pkgs.coreutils}/bin/cut -f 5 -d " " | ${pkgs.gawk}/bin/awk 'NF{print; exit}')"
    if [ -z "$NETDEV" ]; then
      NETDEV="$(${pkgs.iproute2}/bin/ip route show default 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $5; exit}')"
    fi
    if [ -z "$NETDEV" ]; then
      NETDEV="$(${pkgs.iproute2}/bin/ip -6 route show default 2>/dev/null | ${pkgs.gawk}/bin/awk '{print $5; exit}')"
    fi

    if [ -n "$NETDEV" ]; then
      ${pkgs.ethtool}/bin/ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
    fi
  '';
in
{
  imports = [
    "${modulesPath}/virtualisation/google-compute-image.nix"
    ../../nixos-modules
    inputs.sops-nix.nixosModules.sops
  ];

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
  vpn.enable = true;
  reverseProxy.enable = true;

  sops.age.generateKey = true;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  systemd.tmpfiles.rules = [ "d /var/lib/sops-nix 0755 root root -" ];

  sops.secrets = {
    dummy = {
      sopsFile = ../../shared-secrets.sops.yaml;
    };
    tailscale_authkey = {
      sopsFile = ../../shared-secrets.sops.yaml;
    };
  };

  services.tailscale.authKeyFile = config.sops.secrets.tailscale_authkey.path;
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraUpFlags = [
    "--ssh"
    "--advertise-exit-node"
  ];

  systemd.services.tailscale-udp-gro = {
    description = "Enable UDP GRO forwarding for Tailscale exit node";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = tailscaleUdpGro;
    };
  };

  security.tpm2 = {
    enable = lib.mkForce false;
    pkcs11.enable = lib.mkForce false;
    tctiEnvironment.enable = lib.mkForce false;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = false;
    };
  };

  users.users.bc.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc7XLm936xcCFngohG73fs9T5lfikrHzYHErvGF+mna"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIc7XLm936xcCFngohG73fs9T5lfikrHzYHErvGF+mna"
  ];

  networking.hostName = "gauss";
  time.timeZone = "America/Los_Angeles";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      2022
    ];
  };

  reverseProxy.virtualHosts = {
    "linkding.bede.ai" = {
      upstream = "euler:9090";
    };
    "http://linkding" = {
      upstream = "euler:9090";
      extraConfig = ''
        bind tailscale/linkding
      '';
    };
  };

  nix.settings.require-sigs = false;

  boot.blacklistedKernelModules = [
    "tpm"
    "tpm_crb"
    "tpm_tis"
    "tpm_tis_core"
  ];

  system.stateVersion = "24.05";
}
