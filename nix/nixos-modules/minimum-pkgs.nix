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
      vim # text editor
      git # version control
      wezterm # terminal emulator
      chezmoi # dotfiles
    ];
  };
}
