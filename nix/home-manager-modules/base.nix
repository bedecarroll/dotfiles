{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.base;
in
{

  options = {
    base.enable = mkEnableOption "base environment";
  };

  config = mkIf cfg.enable {
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
