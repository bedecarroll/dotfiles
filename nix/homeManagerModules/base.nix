{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    base.enable = lib.mkEnableOption "base environment";
  };

  config = lib.mkIf config.base.enable {
    home.packages = with pkgs; [
      atuin
      bash
      bash-preexec
      bat
      delta
      eza
      fzf
      git
      git-extras
      jq
      pre-commit
      ripgrep
      tmux
      zoxide
      zsh
    ];
  };
}
