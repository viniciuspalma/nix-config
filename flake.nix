{
  description = "Configuration for macOS, NixOS, and Ubuntu blades";

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

    hosts = import ./hosts;

    hostDeployment = host:
      if host ? deployment
      then host.deployment
      else if host.kind == "darwin"
      then "darwin"
      else "home-manager";

    bladeHosts = lib.filterAttrs (_: host: host.kind == "blade") hosts;
    standaloneBladeHosts =
      lib.filterAttrs (_: host: hostDeployment host == "home-manager") bladeHosts;
    nixosBladeHosts =
      lib.filterAttrs (_: host: hostDeployment host == "nixos") bladeHosts;
    darwinHost = hosts.${darwinHostname};

    mkSpecialArgs = hostname: host:
      inputs
      // {
        inherit username useremail hostname;
        system = host.system;
        isBlade = host.kind == "blade";
        isDarwin = host.kind == "darwin";
        isLinux = host.kind != "darwin";
        isNixOS = hostDeployment host == "nixos";
      };

    darwinSpecialArgs = mkSpecialArgs darwinHostname darwinHost;

    mkHomeModules = host:
      [
        ./home
        nixvimModule
      ]
      ++ lib.optionals (host ? homeModule) [host.homeModule];

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
        modules =
          mkHomeModules host
          ++ [
            {
              home.homeDirectory = "/home/${username}";
            }
          ];
      };

    mkBladeNixosConfiguration = hostname: host: let
      specialArgs = mkSpecialArgs hostname host;
    in
      nixpkgs.lib.nixosSystem {
        system = host.system;
        specialArgs = specialArgs;
        modules = [
          ./nixos/blades/shared
          host.nixosModule
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${username} = {
                ...
              }: {
                imports = mkHomeModules host;
              };
            };
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
              ...
            }: {
              imports = mkHomeModules darwinHost;
            };
          };
        }
      ];
    };

    homeConfigurations =
      lib.mapAttrs'
      (hostname: host:
        lib.nameValuePair "${username}@${hostname}" (mkBladeHomeConfiguration hostname host))
      standaloneBladeHosts;

    nixosConfigurations = lib.mapAttrs mkBladeNixosConfiguration nixosBladeHosts;

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."${darwinHostname}".pkgs;
  };
}
