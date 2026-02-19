{
  username,
  lib,
  isDarwin,
  isLinux,
  ...
}: let
  sharedImports = [
    ./git.nix
    ./go.nix
    ./shell.nix
    ./starship.nix
    ./tmux.nix
    ./nvim
  ];

  darwinImports = [
    ./_1password.nix
    ./core.nix
    ./ghostty.nix
    ./kitty.nix
    ./vscode.nix
    # ./zed.nix
  ];

  linuxImports = [
    ./linux.nix
    ./core-linux.nix
    ./fan-control.nix
  ];
in {
  imports =
    sharedImports
    ++ lib.optionals isDarwin darwinImports
    ++ lib.optionals isLinux linuxImports;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = username;
    # homeDirectory = "/Users/${username}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";

    file."zsh-custom" = {
      source = ./zsh-custom;
    };

    file.".testcontainers.properties" = {
      source = ./.testcontainers.properties;
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
