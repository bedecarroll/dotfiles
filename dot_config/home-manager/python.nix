{ config, pkgs, ... }:

{
  config = {
    # Python programs and frequently needed packages
    home.packages = with pkgs; [
      ruff
      poetry

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
          httpx
          netmiko
          paramiko
          scapy
          textfsm
          networkx
      ]))
    ];
  };
}

