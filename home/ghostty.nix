{
  programs.ghostty = {
    enable = true;
    # On macOS, Ghostty is installed via homebrew cask (see modules/apps.nix).
    # The nixpkgs package is Linux-only.
    package = null;

    settings = {
      font-family = "FiraCode Nerd Font Mono";
      font-size = 16;
      background-opacity = 0.9;
      theme = "Dracula";
      scrollback-limit = 10000;
      window-decoration = false;
    };
  };
}
