{ pkgs, ... }:
{
  # Enough to get the system going
  environment.systemPackages = with pkgs; [
    vim # text editor
    git # version control
    wezterm # terminal emulator
    chezmoi # dotfiles
  ];
}
