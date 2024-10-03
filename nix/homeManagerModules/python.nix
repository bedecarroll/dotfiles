{
  pkgs,
  lib,
  config,
  ...
}:
{

  options = {
    python.enable = lib.mkEnableOption "python pkgs and programs";
  };

  config = lib.mkIf config.python.enable {
    home.packages = with pkgs; [
      # NOTE: some should probaby just use uv
      # aider-chat # moves too fast, use uv
      poetry
      ruff
      ruff-lsp
      sqlfluff # Used for fmt of sql queries
      # uv # uv moves too fast

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
  };
}
