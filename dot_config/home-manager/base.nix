{ config, pkgs, ... }:

{
  config = {
    # Minimum viable environment
    home.packages = with pkgs; [
      git
      tmux
      atuin
      bash-preexec
    ];
  };
}

