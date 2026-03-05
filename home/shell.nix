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
      ];
    };

    initExtra = ''
      _opencode_detect_appearance() {
        local mode
        mode="$(/usr/bin/osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode' 2>/dev/null)"
        if [[ "$mode" == "true" ]]; then
          printf 'dark'
          return 0
        fi
        if [[ "$mode" == "false" ]]; then
          printf 'light'
          return 0
        fi

        local fallback
        fallback="$(/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null)"
        if [[ "$fallback" == "Dark" ]]; then
          printf 'dark'
        else
          printf 'light'
        fi
      }

      _opencode_theme_change_notice() {
        local state_dir="$HOME/.local/state/opencode"
        local state_file="$state_dir/appearance-mode"
        local current previous

        current="$(_opencode_detect_appearance)"

        if [[ ! -f "$state_file" ]]; then
          mkdir -p "$state_dir"
          printf '%s' "$current" > "$state_file"
          return 0
        fi

        previous="$(<"$state_file")"
        if [[ "$current" != "$previous" ]]; then
          printf '%s' "$current" > "$state_file"
          if command -v pgrep >/dev/null 2>&1 && pgrep -x opencode >/dev/null 2>&1; then
            print -P "%F{214}[opencode]%f macOS appearance switched to %B$current%b; restart OpenCode to refresh theme."
          fi
        fi
      }

      autoload -Uz add-zsh-hook
      add-zsh-hook precmd _opencode_theme_change_notice
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Blade users currently log in with bash. Ensure `cd` triggers direnv there too.
  home.activation.direnvBashHook = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail

    bashrc="$HOME/.bashrc"
    hook='eval "$(${pkgs.direnv}/bin/direnv hook bash)"'

    if [ ! -f "$bashrc" ]; then
      ${pkgs.coreutils}/bin/touch "$bashrc"
    fi

    if ! ${pkgs.gnugrep}/bin/grep -Fqx "$hook" "$bashrc"; then
      printf '\n# Added by Home Manager for direnv\n%s\n' "$hook" >> "$bashrc"
    fi
  '';

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
      "/nix/var/nix/profiles/default/bin"
      "${config.home.homeDirectory}/.local/bin"
    ];

  home.shellAliases = {
    agy = "${config.home.homeDirectory}/.antigravity/antigravity/bin/agy";
    k = "kubectl";

    urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
    urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
  };
}
