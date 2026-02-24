let
  darkTheme = "Dracula";
  lightTheme = "GitHub Light Default";
in {
  programs.ghostty = {
    enable = true;
    # On macOS, Ghostty is installed via homebrew cask (see modules/apps.nix).
    # The nixpkgs package is Linux-only.
    package = null;

    settings = {
      font-family = "FiraCode Nerd Font Mono";
      font-size = 16;
      background-opacity = 0.9;
      # Ghostty switches these automatically based on the OS appearance.
      theme = "light:${lightTheme},dark:${darkTheme}";
      scrollback-limit = 10000;
      window-decoration = false;
    };
  };
}
