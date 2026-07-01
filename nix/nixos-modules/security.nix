{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.securityDefaults;
in
{
  options = {
    securityDefaults.enable = mkEnableOption "basic TPM & security tools";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ tpm2-tss ];
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable = true;
    systemd.services.yubikey-ccid-udev-trigger = {
      description = "Apply CCID udev permissions to inserted YubiKeys";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-udevd.service" ];
      serviceConfig.Type = "oneshot";
      path = [ pkgs.systemd ];
      script = ''
        udevadm trigger --action=add --subsystem-match=usb --attr-match=idVendor=1050
      '';
    };
    security.sudo.wheelNeedsPassword = false;
    # https://nixos.wiki/wiki/TPM
    security.tpm2.enable = true;
    security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };
}
