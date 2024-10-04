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
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      openai-whisper-cpp
      pkgs-unstable.aider-chat
      pkgs-unstable.llm
    ];
  };
}
