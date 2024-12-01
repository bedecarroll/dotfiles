{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.ai;
in
{

  options = {
    ai.enable = mkEnableOption "AI tools";
    ai.aider.enable = mkEnableOption "aider";
    ai.llm.enable = mkEnableOption "llm";
  };

  config = mkMerge [
    (mkIf cfg.enable { home.packages = with pkgs; [ openai-whisper-cpp ]; })
    (mkIf cfg.aider.enable { home.packages = [ pkgs-unstable.aider-chat ]; })
    (mkIf cfg.llm.enable { home.packages = [ pkgs-unstable.llm ]; })
  ];
}