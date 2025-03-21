{ username, ... }:

{
  # import sub modules
  imports = [
    ./_1password.nix
    ./core.nix
    ./git.nix
    ./go.nix
    ./kitty.nix
    ./shell.nix
    ./starship.nix
    ./tmux.nix
    ./nvim
    ./zed.nix
  ];

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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
