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
      settings."*".IdentityAgent = lib.mkIf pkgs.stdenv.isDarwin identityAgentSocket;
    }
    else {
      matchBlocks."*".identityAgent = lib.mkIf pkgs.stdenv.isDarwin identityAgentSocket;
    };
in {
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
