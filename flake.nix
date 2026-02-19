{
  description = "Configuration for macOS and Ubuntu blades";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nixvim,
    home-manager,
    nix-vscode-extensions,
    ...
  }: let
    lib = nixpkgs.lib;

    username = "vinicius.palma";
    useremail = "pockvini@gmail.com";
    darwinHostname = "ch-CQTMGK70R5";

    nixvimModule = nixvim.homeModules.nixvim;

    hosts = {
      "${darwinHostname}" = {
        kind = "darwin";
        system = "aarch64-darwin";
      };
      blade-1 = {
        kind = "blade";
        system = "aarch64-linux";
      };
      blade-2 = {
        kind = "blade";
        system = "aarch64-linux";
      };
      blade-3 = {
        kind = "blade";
        system = "aarch64-linux";
      };
    };

    bladeHosts = lib.filterAttrs (_: host: host.kind == "blade") hosts;
    darwinHost = hosts.${darwinHostname};

    mkSpecialArgs = hostname: host:
      inputs
      // {
        inherit username useremail hostname;
        system = host.system;
        isBlade = host.kind == "blade";
        isDarwin = host.kind == "darwin";
        isLinux = host.kind != "darwin";
      };

    darwinSpecialArgs = mkSpecialArgs darwinHostname darwinHost;

    mkBladeHomeConfiguration = hostname: host: let
      pkgs = import nixpkgs {
        system = host.system;
        config.allowUnfree = true;
      };
      specialArgs = mkSpecialArgs hostname host;
    in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgs;
        modules = [
          ./home
          nixvimModule
          {
            home.homeDirectory = "/home/${username}";
          }
        ];
      };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Viniciuss-MacBook-Pro
    darwinConfigurations."${darwinHostname}" = nix-darwin.lib.darwinSystem {
      system = darwinHost.system;
      specialArgs = darwinSpecialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/apps.nix
        ./modules/system.nix
        ./modules/host-users.nix
        home-manager.darwinModules.home-manager
        {
          nixpkgs.overlays = [
            nix-vscode-extensions.overlays.default
          ];
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = darwinSpecialArgs;
            users.${username} = {
              config,
              lib,
              pkgs,
              ...
            }: {
              imports = [
                ./home
                nixvimModule
              ];
            };
          };
        }
      ];
    };

    homeConfigurations =
      lib.mapAttrs'
      (hostname: host:
        lib.nameValuePair "${username}@${hostname}" (mkBladeHomeConfiguration hostname host))
      bladeHosts;

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."${darwinHostname}".pkgs;
  };
}
