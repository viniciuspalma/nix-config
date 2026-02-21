{
  lib,
  pkgs,
  ...
}: let
  packages = with pkgs; [
    git
    coreutils
    findutils
    nnn

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep
    jq
    yq-go
    fzf

    # misc
    aria2
    socat
    nmap
    htop
    _1password-cli
    ffmpeg
    cowsay
    file
    which
    tree
    direnv
    gh
    copier
    mkcert
    lazygit
    gnumake
    pkg-config
    gcc

    # languages
    go
    opam
    nodejs
    ruby_3_3
    python312
    alejandra

    # devops
    google-cloud-sdk
    docker
    podman
    podman-compose
    qemu
    google-cloud-sql-proxy
    kubectl
    kubectx
    k9s
    pgcli
    teller
    supabase-cli
    terramate
    opentofu
    awscli2
  ];
in {
  # Skip packages that are not available on aarch64-linux.
  home.packages = lib.filter (pkg: lib.meta.availableOn pkgs.stdenv.hostPlatform pkg) packages;
}
