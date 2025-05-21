{
  description = "NixOS configurations";

  # nixConfig = {
  #   extra-substituters = [ "https://nix-community.cachix.org" ];
  #   extra-trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  #   ];
  # };

  inputs = {
    catppuccin.url = "github:catppuccin/nix";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    disko.url = "github:nix-community/disko";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.0";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      disko,
      home-manager,
      determinate,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        kepler = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/kepler/configuration.nix
            disko.nixosModules.disko
            ./nix/system-configs/kepler/disko-config.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-11th-gen
            #inputs.stylix.nixosModules.stylix
            determinate.nixosModules.default
          ];
        };
        euler = nixpkgs.lib.nixosSystem {
          specialArgs = {
            # Provide inputs so modules can import sops-nix
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/euler/configuration.nix
          ];
        };
      };
      homeConfigurations = {
        "bc@kepler" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/kepler/home.nix
            inputs.catppuccin.homeModules.catppuccin
          ];
        };
        "bc@liberty" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/liberty/home.nix
            inputs.catppuccin.homeModules.catppuccin
          ];
        };
      };
      # Export wallpapers as a package
      packages = {
        wallpapers = pkgs.callPackage ./nix/wallpapers/default.nix { };
      };
    };
}
