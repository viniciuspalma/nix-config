{
  pkgs,
  username,
  ...
}: let
  # Existing key currently present on blade hosts (managed in 1Password).
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf3+Pnj8acqkAAJNK0WVQrJ/5rIomxxi4U6rCRpIK+v"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwafwyM4cRJuTNkEKCn6onqh8mD7wYcq4abZcAdbXTw"
  ];
in {
  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    # Temporary bootstrap password for first SSH access after USB install.
    # Change immediately after login.
    initialPassword = "nixos";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = sshKeys;
  };

  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  nix.settings.trusted-users = [
    "root"
    username
  ];
}
