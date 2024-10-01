{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-hardware, disko, home-manager, ... } @ inputs:
  let
        system = "x86_64-linux";
     pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      kepler = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
           ./hosts/kepler/configuration.nix
           disko.nixosModules.disko
           ./hosts/kepler/disko-config.nix
           nixos-hardware.nixosModules.lenovo-thinkpad-x1-11th-gen
           #inputs.stylix.nixosModules.stylix
        ];
      };
    };
    homeConfigurations."bc" = home-manager.lib.homeManagerConfiguration {
       inherit pkgs;
       modules = [
         ./homeManagerModules
       ];
    };
  };
}
