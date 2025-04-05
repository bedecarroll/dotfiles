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
      dotenv-linter
      entr
      gh
      git-extras
      grex # generate regex from test cases
      jujutsu
      just
      lazygit
      pkgs-unstable.mise
      pre-commit
      tig
      typos
      watchexec
    ];
  };
}
