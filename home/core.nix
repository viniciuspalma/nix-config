{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nnn # terminal file manager

    # archives
    zip # A compression and file packaging utility
    xz # General-purpose data compression with high compression ratio
    unzip # A utility for extracting and viewing files in .zip archives
    p7zip # A file archiver with highest compression ratio

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    fzf # A command-line fuzzy finder
    
    # libs
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    htop # An interactive process viewer for Unix
    ffmpeg # A complete, cross-platform solution to record, convert and stream audio and video
    glm # OpenGL Mathematics (GLM)
    giflib # A library for reading and writing gif images
    libpng # A collection of routines used to create PNG format graphics files
    boost # Free peer-reviewed portable C++ source libraries
    glew # The OpenGL Extension Wrangler Library
    freetype # A software library to render fonts
    libffi # A portable foreign-function interface library
    pkg-config # A helper tool used when compiling applications and libraries

    # misc
    cowsay # Configurable talking cow
    file # A utility to determine file types
    which # A utility to show the full path of commands
    tree # A utility to display a tree view of directories
    direnv # An environment switcher for the shell
    ripgrep # recursively searches directories for a regex pattern
    fzf # A command-line fuzzy finder
    gh # GitHub CLI
    copier # A library for rendering projects templates
    caligula # A tool for disk image tool
    mkcert # A simple tool to make locally-trusted development certificates
    
    # languages
    go
    opam
    nodejs
    ruby_3_3
    python312
    
    # devops
    (
     google-cloud-sdk.withExtraComponents [
     google-cloud-sdk.components.gke-gcloud-auth-plugin
     google-cloud-sdk.components.cbt
     google-cloud-sdk.components.bigtable
     ]
    )
    colima	
    docker
    podman
    podman-compose
    qemu
    google-cloud-sql-proxy
    kubectl
    kubectx
    telepresence2
    k9s
    pgcli
    firebase-tools
    teller
    supabase-cli
    gotrue-supabase
    terramate
    opentofu
    awscli2

    # testing
    ddosify
    delve
    k6
    ghz
    pre-commit
    httpie

    # protobuf
    protoc-gen-go
    protobuf

    # linting - formatting
    eslint_d
    nodePackages_latest.prettier_d_slim 
  ];
}
