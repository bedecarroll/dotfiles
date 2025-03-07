{
  pkgs,
  lib,
  config,
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
      direnv # .envrc files to autoload
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
      mise
    ];
  };
}
