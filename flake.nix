{
  description = "NixOS configurations";

  inputs = {
    deploy-rs.url = "github:serokell/deploy-rs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    disko.url = "github:nix-community/disko";
    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/*";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      disko,
      home-manager,
      determinate,
      nixos-generators,
      deploy-rs,
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
            determinate.nixosModules.default
          ];
        };
        euler = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/euler/configuration.nix
            determinate.nixosModules.default
          ];
        };
        pascal = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/pascal/configuration.nix
            determinate.nixosModules.default
          ];
        };
        gauss = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/gauss/configuration.nix
            determinate.nixosModules.default
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
          ];
        };
        "bc@newton" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/liberty/home.nix
          ];
        };
      };
      packages.${system} = {
        wallpapers = pkgs.callPackage ./nix/wallpapers/default.nix { };
      };

      vms.${system} = {
        euler = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./nix/system-configs/euler/configuration.nix
          ];
          format = "proxmox";
        };
      };

      # Deploy-rs configuration for remote deployment
      deploy.nodes = {
        euler = {
          hostname = "euler";
          sshUser = "bc";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.euler;
          };
        };
        pascal = {
          hostname = "159.54.182.73"; # Use IP address or hostname
          sshUser = "root";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.pascal;
          };
        };
        gauss = {
          hostname = "gauss";
          sshUser = "bede_carroll_todoku_com";
          profiles.system = {
            user = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.gauss;
          };
        };
      };

      # Deploy checks to prevent deployment mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
