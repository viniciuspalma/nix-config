{
  pkgs,
  lib,
  system,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault system;
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      # Keep password auth enabled during migration; tighten later per-host.
      PasswordAuthentication = lib.mkDefault true;
      KbdInteractiveAuthentication = lib.mkDefault true;
      PermitRootLogin = lib.mkDefault "no";
    };
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    vim
  ];

  # First NixOS deployment for blade nodes.
  system.stateVersion = "24.11";
}
