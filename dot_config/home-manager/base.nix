{ config, pkgs, ... }:

{
  config = {
    # Minimum viable environment
    home.packages = with pkgs; [
      tmux
      neovim
      atuin
      bash-preexec
    ];
  };
}

