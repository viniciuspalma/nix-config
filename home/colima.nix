{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.programs.colima;
  yamlFormat = pkgs.formats.yaml {};
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

      home.file.".colima/${cfg.profile}/colima.yaml".source =
        yamlFormat.generate "colima-${cfg.profile}.yaml" cfg.settings;
    })
  ];
}
