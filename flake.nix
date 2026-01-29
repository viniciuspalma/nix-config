{
  description = "Configuration MacOs";

  inputs = {
    nixpkgs = {
      # url = "github:NixOS/nixpkgs/master";
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nixvim, home-manager, ... }:
    let
      username  = "vinicius.palma";
      hostname  = "ch-CQTMGK70R5"; 
      system    = "aarch64-darwin";
      useremail = "pockvini@gmail.com";

      nixvimModule = nixvim.homeManagerModules.nixvim;

      specialArgs =
        inputs
        // {
          inherit username hostname system useremail;
        };
    in
      {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Viniciuss-MacBook-Pro
      darwinConfigurations."${hostname}" = nix-darwin.lib.darwinSystem {
        inherit system specialArgs;
        modules = [
          ./modules/nix-core.nix
          ./modules/apps.nix
          ./modules/system.nix
          ./modules/host-users.nix
          home-manager.darwinModules.home-manager
          {
            home-manager = { 
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${username} = { config, lib, pkgs, ... }: {
                imports = [
                  ./home
                  nixvimModule
                ];
              };
            };  
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."${hostname}".pkgs;
    };
}
