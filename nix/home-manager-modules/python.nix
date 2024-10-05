{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.python;
in
{

  options = {
    python.enable = mkEnableOption "python pkgs and programs";
    python.uv.enable = mkEnableOption "install uv";
  };

  config = mkMerge [
    # This is an option because UV outside of nixpkgs is better
    (mkIf cfg.uv.enable { home.packages = with pkgs; [ uv ]; })
    (mkIf cfg.enable {
      home.packages = with pkgs; [
        poetry
        ruff
        sqlfluff # Used for fmt of sql queries

        # always available py packages
        (python3.withPackages (
          ps: with ps; [
            click
            httpx
            ipdb
            neovim
            netmiko
            networkx
            numpy
            pandas
            paramiko
            pip
            polars
            pygments
            scapy
            scipy
            seaborn
            setuptools
            textfsm
          ]
        ))
      ];
    })
  ];
}
