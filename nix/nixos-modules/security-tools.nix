{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    onepw.enable = lib.mkEnableOption "enable 1password";
  };

  config = lib.mkIf config.onepw.enable {
    # https://nixos.wiki/wiki/1Password
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "bc" ];
    };
  };
}
