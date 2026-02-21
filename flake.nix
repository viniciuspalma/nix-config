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

    disko = {
      url = "github:nix-community/disko";
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
    disko,
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
        ]
        ++ lib.optionals (host ? diskoModule) [
          disko.nixosModules.disko
          host.diskoModule
        ]
        ++ [
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${username} = {...}: {
                imports = mkHomeModules host;
              };
            };
          }
        ];
      };

    mkBladeRecoveryImageConfiguration = hostname: host: let
      specialArgs = mkSpecialArgs hostname host;
    in
      nixpkgs.lib.nixosSystem {
        system = host.system;
        specialArgs = specialArgs;
        modules = [
          ./nixos/blades/shared
          host.nixosModule
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          ({config, ...}: {
            # Build a recovery image with a larger firmware partition so
            # extlinux + firmware artifacts fit reliably on CM4.
            sdImage = {
              firmwareSize = 512;
              firmwarePartitionName = "system-boot";
              rootVolumeLabel = "writable";
              # Ensure the generated image already contains extlinux + nixos
              # entries on the firmware FAT so CM4 can boot without a prior
              # activation step.
              populateFirmwareCommands = lib.mkAfter ''
                ${config.boot.loader.generic-extlinux-compatible.populateCmd} \
                  -c ${config.system.build.toplevel} \
                  -d firmware
              '';
            };

            # The sd-image module enables a generic "all hardware" initrd
            # profile that includes modules missing from linux-rpi (e.g.
            # dw-hdmi). Keep this recovery image focused on CM4+NVMe boot.
            hardware.enableAllHardware = lib.mkForce false;
            boot.initrd.availableKernelModules = lib.mkForce [
              "nvme"
              "pcie-brcmstb"
              "mmc_block"
              "usbhid"
              "usb_storage"
              "xhci-pci"
              "xhci-hcd"
              "xhci-plat-hcd"
              "xhci-pci-renesas"
            ];

            fileSystems."/boot/firmware" = {
              device = lib.mkForce "/dev/disk/by-label/system-boot";
              fsType = lib.mkForce "vfat";
              options = lib.mkForce [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          })
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${username} = {...}: {
                imports = mkHomeModules host;
              };
            };
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

    nixosConfigurations =
      (lib.mapAttrs mkBladeNixosConfiguration nixosBladeHosts)
      // {
        blade-1-recovery = mkBladeRecoveryImageConfiguration "blade-1" hosts.blade-1;
      };

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
