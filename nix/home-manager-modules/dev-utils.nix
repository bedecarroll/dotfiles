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
      dotenv-linter
      entr
      gh
      git-extras
      grex # generate regex from test cases
      lazygit
      pre-commit
      tig
      watchexec
      jujutsu
      just
      pkgs-unstable.mise
    ];
  };
}
