{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    rust.enable = lib.mkEnableOption "standard rust toolchain";
  };

  config = lib.mkIf config.rust.enable {
    home.packages = with pkgs; [
      rustc
      cargo
      rust-analyzer
      gcc14
      nodejs_22
      tree-sitter
    ];
  };
}
