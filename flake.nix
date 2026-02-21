{
  description = "Configuration for macOS and Linux blades";

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

    zeroclawSrc = {
      url = "github:zeroclaw-labs/zeroclaw?ref=main";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nixvim,
    home-manager,
    nix-vscode-extensions,
    zeroclawSrc,
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

    zeroclawSystems = ["aarch64-linux"];

    mkZeroclawPackage = system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
      pkgs.rustPlatform.buildRustPackage {
        pname = "zeroclaw";
        version = "unstable-main";
        src = zeroclawSrc;

        cargoLock = {
          lockFile = "${zeroclawSrc}/Cargo.lock";
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs;
          lib.optionals stdenv.hostPlatform.isLinux [
            openssl
          ];

        doCheck = false;

        meta = with lib; {
          description = "Open source AI coding agent for software engineering tasks";
          homepage = "https://github.com/zeroclaw-labs/zeroclaw";
          license = licenses.mit;
          mainProgram = "zeroclaw";
          platforms = platforms.linux;
        };
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
            users.${username} = {...}: {
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

    packages = lib.genAttrs zeroclawSystems (system: let
      zeroclaw = mkZeroclawPackage system;
    in {
      inherit zeroclaw;
      default = zeroclaw;
    });

    apps = lib.genAttrs zeroclawSystems (system: let
      program = "${self.packages.${system}.zeroclaw}/bin/zeroclaw";
    in {
      zeroclaw = {
        type = "app";
        inherit program;
      };
      default = {
        type = "app";
        inherit program;
      };
    });

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."${darwinHostname}".pkgs;
  };
}
