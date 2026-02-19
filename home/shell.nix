{
  lib,
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    syntaxHighlighting = {
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
        "direnv"
      ];
    };
  };

  home.sessionVariables =
    {
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
      "${config.home.homeDirectory}/.local/bin"
    ];

  home.shellAliases = {
    agy = "${config.home.homeDirectory}/.antigravity/antigravity/bin/agy";
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
