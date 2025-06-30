{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.dev-utils;
in
{

  options = {
    dev-utils.enable = mkEnableOption "dev focused extras";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cookiecutter
      difftastic
      dotenv-linter
      entr
      gh
      git-extras
      grex # generate regex from test cases
      just
      lazygit
      markdownlint-cli2
      mergiraf
      pkgs-unstable.jujutsu
      pkgs-unstable.mise
      pre-commit
      sqlite-interactive
      tig
      typos
      watchexec
    ];
  };
}
