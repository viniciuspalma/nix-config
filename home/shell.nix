{
  lib,
  config,
  pkgs,
  ...
}: let
  forgeBootstrapBin = "${pkgs.llm-agents.forge}/bin/forge";
  userForgeBin = "${config.home.homeDirectory}/.local/bin/forge";
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    syntaxHighlighting = {
      enable = true;
    };

    autosuggestion = {
      enable = true;
    };

    oh-my-zsh = {
      enable = true;

      custom = "$HOME/zsh-custom";
      theme = "dracula-pro";

      plugins = [
        "git"
        "golang"
        "kubectl"
        "helm"
        "gcloud"
        "docker"
        "kubectl"
      ];
    };

    initContent = ''
      export FORGE_BIN="${userForgeBin}"
      if [[ ! -x "$FORGE_BIN" ]]; then
        export FORGE_BIN="${forgeBootstrapBin}"
      fi

      eval "$("$FORGE_BIN" zsh plugin | ${pkgs.gnused}/bin/sed 's/compdef _forge forge$/compdef _forge forge-agent/')"
      eval "$("$FORGE_BIN" zsh theme)"
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables =
    {
      FORGE_BIN = userForgeBin;
      FORGE_BOOTSTRAP_BIN = forgeBootstrapBin;
      USE_GKE_GCLOUD_AUTH_PLUGIN = "True";
    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      ANDROID_HOME = "${config.home.homeDirectory}/Library/Android/sdk";
    };

  home.sessionPath =
    [
      "${config.home.homeDirectory}/.antigravity/antigravity/bin"
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      "/Users/vini/.gem/ruby/3.3.0/bin"
      "/opt/homebrew/bin"
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      "/nix/var/nix/profiles/default/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

  home.shellAliases = {
    agy = "${config.home.homeDirectory}/.antigravity/antigravity/bin/agy";
    f = "forge-agent";
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
