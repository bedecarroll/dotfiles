{ pkgs, ... }:

{
  config = {
    # Security packages
    home.packages = with pkgs; [ cacert ];
  };
}

