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
    security.sudo.wheelNeedsPassword = false;
    # https://nixos.wiki/wiki/TPM
    security.tpm2.enable = true;
    security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };
}
