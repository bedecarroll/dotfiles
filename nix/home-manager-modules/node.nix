{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.node;
  bun_1_3_14 = pkgs.bun.overrideAttrs {
    version = "1.3.14";
    src = pkgs.fetchurl {
      url = "https://github.com/oven-sh/bun/releases/download/bun-v1.3.14/bun-linux-x64.zip";
      hash = "sha256-lR7iruhV8IWVruxiJSJqKY0/6oOj3NZGXAnLzN9+hI8=";
    };
  };
in
{

  options = {
    node.enable = mkEnableOption "node/js pkgs";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs_22
      bun_1_3_14
    ];
  };
}
