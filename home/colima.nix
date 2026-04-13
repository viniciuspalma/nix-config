{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.colima;
  yamlFormat = pkgs.formats.yaml {};
  colimaConfig = yamlFormat.generate "colima-${cfg.profile}.yaml" cfg.settings;
  colimaConfigTarget = "${config.home.homeDirectory}/.colima/${cfg.profile}/colima.yaml";
in {
  options.programs.colima = {
    enable = lib.mkEnableOption "Colima";

    profile = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Colima profile name managed by Home Manager.";
    };

    settings = lib.mkOption {
      type = yamlFormat.type;
      default = {
        cpu = 8;
        disk = 100;
        memory = 16;
        arch = "aarch64";
        runtime = "docker";
        autoActivate = true;
        mountInotify = true;
        vmType = "vz";
        mountType = "virtiofs";
        rosetta = false;
        binfmt = true;
        docker = {};
        kubernetes = {
          enabled = false;
        };
      };
      description = ''
        Declarative Colima profile settings written to
        `~/.colima/<profile>/colima.yaml`.
      '';
      example = {
        memory = 8;
        vmType = "vz";
        mountType = "virtiofs";
        rosetta = true;
      };
    };
  };

  config = lib.mkMerge [
    {
      programs.colima.enable = lib.mkDefault pkgs.stdenv.isDarwin;
    }

    (lib.mkIf cfg.enable {
      home.sessionVariables = {
        DOCKER_HOST = "unix://${config.home.homeDirectory}/.colima/${cfg.profile}/docker.sock";
      };

      # Colima rewrites its profile config during startup, so this needs to be a
      # regular file in $HOME instead of a read-only symlink into the Nix store.
      home.activation.colimaConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
        target="${colimaConfigTarget}"
        source="${colimaConfig}"

        $DRY_RUN_CMD mkdir -p "$(dirname "$target")"
        if [ ! -e "$target" ] || [ -L "$target" ] || ! cmp -s "$source" "$target"; then
          $DRY_RUN_CMD rm -f "$target"
          $DRY_RUN_CMD cp "$source" "$target"
          $DRY_RUN_CMD chmod 0644 "$target"
        fi
      '';
    })
  ];
}
