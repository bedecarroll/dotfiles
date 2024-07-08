{ config, pkgs, ... }:

{
  config = {
    # Packages for Rust setup
    home.packages = with pkgs; [ rustc cargo rust-analyzer ];
  };
}

