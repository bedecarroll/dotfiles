{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ tpm2-tss ];
  services.udev.packages = [ pkgs.yubikey-personalization ];
  security.sudo.wheelNeedsPassword = false;
}
