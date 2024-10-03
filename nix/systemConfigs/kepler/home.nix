{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "bc";
  home.homeDirectory = "/home/bc";

  # https://github.com/nix-community/home-manager/issues/432#issuecomment-434817038
  #programs.man.enable = false;
  #home.extraOutputsToInstall = [ "man" ];
  # https://github.com/nix-community/home-manager/issues/432#issuecomment-615841327
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree programs
  nixpkgs.config.allowUnfreePredicate = _: true;

  # Golang
  programs.go.enable = true;

  imports = [ ../../homeManagerModules ];
}