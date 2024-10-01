{ pkgs, lib, config, ... }: {

  options = {
    iac.enable = lib.mkEnableOption "common iac packages";
  };

  config = lib.mkIf config.iac.enable {
    home.packages = with pkgs; [
      ansible
      #ansible-later
      ansible-lint
      #awscli2
      terraform
      terraformer
    ];
  };
}

