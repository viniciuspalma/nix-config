{
  lib,
  pkgs,
  fan ? {
    canControl = false;
    canReadTach = false;
  },
  isBlade ? false,
  username,
  ...
}: let
  canControl = fan.canControl or false;
  canReadTach = fan.canReadTach or false;

  fanPython = pkgs.python312.withPackages (ps: [
    ps.gpiozero
    ps.lgpio
  ]);

  fanControlBin = pkgs.writeShellApplication {
    name = "fan-control-service";
    runtimeInputs = [fanPython];
    text = ''
      exec python3 ${./fan/fan_control.py} "$@"
    '';
  };

  fanReadBin = pkgs.writeShellApplication {
    name = "fan-read-rpm";
    runtimeInputs = [fanPython];
    text = ''
      exec python3 ${./fan/read_fan_speed.py} "$@"
    '';
  };
in
  lib.mkIf isBlade {
    home.packages =
      lib.optionals canControl [fanControlBin]
      ++ lib.optionals canReadTach [fanReadBin];

    home.file =
      lib.optionalAttrs canReadTach {
        ".config/fan-control/read_fan_speed.py" = {
          source = ./fan/read_fan_speed.py;
          executable = true;
        };
      }
      // lib.optionalAttrs canControl {
        ".config/fan-control/fan_control.py" = {
          source = ./fan/fan_control.py;
          executable = true;
        };
        ".config/fan-control/fan-control.service" = {
          source = ./fan/fan-control.service;
        };
      };

    home.shellAliases =
      lib.optionalAttrs canControl {
        fanctl = "sudo /home/${username}/.nix-profile/bin/fan-control-service";
      }
      // lib.optionalAttrs canReadTach {
        fanrpm = "/home/${username}/.nix-profile/bin/fan-read-rpm";
      };
  }
