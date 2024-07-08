{ config, pkgs, ... }:

{
  config = {
    # Commonly needed IaC packages
    home.packages = with pkgs; [ llm ];
  };
}

