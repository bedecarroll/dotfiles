{ config, pkgs, ... }:

{
  config = {
    # Python programs and frequently needed packages
    home.packages = with pkgs; [
      ruff
      ruff-lsp
      poetry
      sqlfluff # Used for fmt of sql queries

      (python3.withPackages (ps:
        with ps; [
          pip
          setuptools
          neovim
          ipdb
          click
          pygments
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

