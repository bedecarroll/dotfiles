{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.rust;
in
{

  options = {
    rust.enable = mkEnableOption "standard rust toolchain";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cargo
      cargo-flamegraph
      clippy
      mdbook
      rust-analyzer
      rustc
      rustfmt
    ];
  };
}
