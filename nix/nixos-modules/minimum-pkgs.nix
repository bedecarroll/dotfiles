{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.minimumPackages;
in
{
  options = {
    minimumPackages.enable = mkEnableOption "minimum system packages";
  };
  config = mkIf cfg.enable {
    # Enough to get the system going
    environment.systemPackages = with pkgs; [
      age # encryption tool for SOPS
      chezmoi # dotfiles
      git # version control
      vim # text editor
      wezterm # terminal emulator
    ];
  };
}
