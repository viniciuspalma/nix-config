{ pkgs, ...}: {

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
    bat
    cargo
    rustc
    nodejs
    go
    kubectl
    kubectx
    (
      google-cloud-sdk.withExtraComponents [
	google-cloud-sdk.components.gke-gcloud-auth-plugin
        google-cloud-sdk.components.cbt
        google-cloud-sdk.components.bigtable
      ]
    )
    telepresence2
    direnv
    fzf
    tmux
    k9s
    ripgrep
    ghz
    pgcli
    k6
    ddosify
    ffmpeg
    gh
    pre-commit
    protoc-gen-go
    delve
    protobuf
    python312
    python311Packages.pip
    freetype
    giflib
    libpng
    boost
    glew
    glm
    opam
    copier
    podman
    podman-compose
    qemu
    eslint_d
    nodePackages_latest.prettier_d_slim
  ];

  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
    ];

    # `brew install`
    # TODO Feel free to add your favorite apps here.
    brews = [
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "google-chrome"
      "1password"

      # IM & audio & remote desktop & meeting
      "telegram"
      "discord"

      "anki"
      "iina" # video player
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "stats" # beautiful system monitor

      # Development
      "insomnia" # REST client
      "wireshark" # network analyzer
    ];
  };
}
