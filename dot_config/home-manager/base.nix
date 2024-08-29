{ pkgs, ... }:

{
  config = {
    # Minimum viable environment
    home.packages = with pkgs; [
      bash
      zsh
      git
      git-extras
      pre-commit
      tmux
      atuin
      bash-preexec
      zoxide
      eza
      bat
      ripgrep
      jq
      fzf
      delta
    ];
  };
}

