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
      (lib.hiPrio clang)
      cargo-audit
      cargo-binutils
      cargo-flamegraph
      cargo-llvm-cov
      cargo-nextest
      cargo-tarpaulin
      lld
      mdbook
      rustc
      rustup
      sccache
    ];
  };
}
