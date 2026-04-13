{
  description = "Personal macOS nix-darwin configuration";
  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nixvim,
    home-manager,
    nix-vscode-extensions,
    llm-agents,
    ...
  }: let
    lib = nixpkgs.lib;

    username = "vinicius.palma";
    useremail = "pockvini@gmail.com";
    darwinHostname = "ch-CQTMGK70R5";

    hosts = import ./hosts;
    darwinHost = hosts.${darwinHostname};
    nixvimModule = nixvim.homeModules.nixvim;

    darwinSpecialArgs =
      inputs
      // {
        inherit username useremail;
        hostname = darwinHostname;
        system = darwinHost.system;
        isBlade = false;
        isDarwin = true;
        isLinux = false;
        isNixOS = false;
      };

    mkHomeModules = host:
      [
        ./home
        nixvimModule
      ]
      ++ lib.optionals (host ? homeModule) [host.homeModule];
  in {
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
            llm-agents.overlays.default
          ];
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "hm-backup";
            overwriteBackup = true;
            extraSpecialArgs = darwinSpecialArgs;
            users.${username} = {...}: {
              imports = mkHomeModules darwinHost;
            };
          };
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."${darwinHostname}".pkgs;
  };
}
