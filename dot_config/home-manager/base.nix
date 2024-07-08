{ config, pkgs, ... }:

{
  config = {
    # Minimum viable environment
    home.packages = with pkgs; [
      git
      git-extras
      pre-commit
      tmux
      atuin
      bash-preexec
      zoxide
    ];
  };
}

