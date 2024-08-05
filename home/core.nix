{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    cowsay
    file
    which
    tree

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
    google-cloud-sql-proxy
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
    eslint_d
    nodePackages_latest.prettier_d_slim

    podman
    podman-compose
    qemu
    
    caligula
  ];
}
