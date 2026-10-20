{pkgs, ...}: {
  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  # TODO Fell free to modify this file to fit your needs.
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    git
    coreutils-full
    findutils
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      # Use supported Homebrew flags to remove unlisted packages and zap cask files.
      cleanup = "none";
      extraFlags = [ "--force-cleanup" "--zap" ];
    };

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
      "vfkit"
      "sui"
      "leapp-cli"
      "pgweb" #
    ];

    # Homebrew 6 requires explicit trust for formulae from third-party taps.
    extraConfig = ''
      tap "withgraphite/tap", trusted: { formula: "graphite" }
      brew "graphite"

      # vLLM with the Metal backend for Apple Silicon (repo is not named homebrew-*, so needs the URL)
      tap "vllm-project/vllm-metal", "https://github.com/vllm-project/vllm-metal", trusted: { formula: "vllm-metal" }
      brew "vllm-metal"

      # Rive CLI: build and preview .riv files from the terminal (the "rive" cask is only the editor)
      tap "rive-app/tap", trusted: { cask: "rive-cli" }
      cask "rive-cli"
    '';

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "google-chrome"
      "zen"
      "1password"
      "1password-cli@beta"
      "wifiman"

      # IM & audio & remote desktop & meeting
      "telegram"
      "discord"
      "spotify"

      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "stats" # beautiful system monitor
      "nordvpn" # VPN

      # Development
      "android-studio" # Android development
      "apidog" # RESTful API client
      "insomnia" # RESTful API client
      "postman" # RESTful API client
      "leapp" # Cloud with aws
      "notion" # Note-taking and organization
      "figma" # Design tool
      "rive" # Interactive animation design tool
      "dbeaver-community" # Database management too
      "proxyman" # HTTP Debugging Proxy
      "ghostty" # GPU-accelerated terminal emulator
    ];
  };
}
