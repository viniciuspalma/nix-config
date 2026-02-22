{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../../home/linux.nix
    ../../home/core-linux.nix
    ../../home/openclaw.nix
  ];

  home.packages = [
    pkgs.gmailctl
  ];

  programs.git.settings.user = {
    name = lib.mkForce "visionary-devi";
    email = lib.mkForce "devi@code-visionary.com";
  };
}
