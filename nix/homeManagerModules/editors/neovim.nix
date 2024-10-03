{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  ...
}:
{

  options = {
    neovim.enable = lib.mkEnableOption "editors etc";
  };

  config = lib.mkIf config.neovim.enable {
    home.packages = with pkgs; [
      nano
      glow
      (pkgs-unstable.neovim.override { extraLuaPackages = ps: with ps; [ jsregexp ]; })
    ];
  };
}
