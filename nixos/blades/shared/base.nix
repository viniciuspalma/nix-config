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
    openFirewall = true;
    settings = {
      # Temporary for USB recovery flow; switch back to key-only after first login.
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
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
