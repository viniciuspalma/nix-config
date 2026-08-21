{
  pkgs,
  lib,
  options,
  ...
}: let
  identityAgentSocket = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
  # Home Manager renamed matchBlocks to settings; keep this compatible with older locks.
  sshAgentConfig =
    if options.programs.ssh ? settings
    then {
      settings = {
        "*".IdentityAgent = lib.mkIf pkgs.stdenv.isDarwin identityAgentSocket;
        "github-work" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/github-work.pub";
          IdentitiesOnly = true;
        };
        "github-personal" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/github-personal.pub";
          IdentitiesOnly = true;
        };
      };
    }
    else {
      matchBlocks = {
        "*".identityAgent = lib.mkIf pkgs.stdenv.isDarwin identityAgentSocket;
        "github-work" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/github-work.pub";
          identitiesOnly = true;
        };
        "github-personal" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/github-personal.pub";
          identitiesOnly = true;
        };
      };
    };
in {
  # Public-key references select identities from the shared 1Password agent.
  home.file.".ssh/github-work.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4Ui+Y6xg4kve+83QVZ5tcA/UQKthFrVPgUIiGFkPql GitHub work (1Password)
  '';
  home.file.".ssh/github-personal.pub".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICf3+Pnj8acqkAAJNK0WVQrJ/5rIomxxi4U6rCRpIK+v GitHub personal (1Password)
  '';

  home.packages =
    (lib.optionals pkgs.stdenv.isLinux (with pkgs; [
      _1password-cli
    ]))
    ++ (with pkgs; [
      gh
    ]);

  programs.zsh.envExtra = ''
    # For 1Password CLI. This requires `pkgs.gh` to be installed.
    # source $HOME/.config/op/plugins.sh
  '';

  programs.ssh =
    {
      enable = true;
      enableDefaultConfig = false;
    }
    // sshAgentConfig;
}
