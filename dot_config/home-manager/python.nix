{ config, pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      ruff  
      poetry
      jupyter
      
      (python3.withPackages (ps:
        with ps; [
          pip
          setuptools
          ipdb
          click
          pygments
          ruff-lsp
          pandas
          numpy
          scipy
          seaborn
          polars
          requests
          netmiko
          paramiko
          scapy
          textfsm
          networkx
      ]))
    ];
  };
}

