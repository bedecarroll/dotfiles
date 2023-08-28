{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      tmux
      neovim
      atuin
      bash-preexec
    ];
  };
}

