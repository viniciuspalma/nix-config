{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  home.packages = [
    self.packages.${pkgs.system}.zeroclaw
    pkgs.sqlite
  ];

  home.shellAliases = {
    zc = "zeroclaw";
  };

  home.file.".zeroclaw/config.template.toml".source = ./zeroclaw/config.template.toml;
  home.file.".zeroclaw/workspace/skills/gmailctl".source = ../skills/gmailctl;
  home.file.".config/systemd/user/zeroclaw.service.d/10-environment.conf".text = ''
    [Service]
    Environment="PATH=${config.home.homeDirectory}/.nix-profile/bin:${config.home.homeDirectory}/.local/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
    Environment="SHELL=/bin/bash"
  '';

  home.activation.zeroclawSyncConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail

    config_dir="$HOME/.zeroclaw"
    template_file="$config_dir/config.template.toml"
    config_file="$config_dir/config.toml"
    discord_token_file="$config_dir/secrets/discord_bot_token"

    if [ -f "$template_file" ]; then
      ${pkgs.coreutils}/bin/install -m 600 "$template_file" "$config_file"
    fi

    if [ -f "$config_file" ] && [ -f "$discord_token_file" ]; then
      token="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$discord_token_file")"

      if [ -n "$token" ]; then
        token_escaped="$(printf '%s' "$token" | ${pkgs.gawk}/bin/awk '{gsub(/\\/,"\\\\"); gsub(/"/,"\\\""); printf "%s", $0}')"
        tmp_file="$(mktemp)"

        ${pkgs.gawk}/bin/awk -v token="$token_escaped" '
          BEGIN {
            in_discord = 0
            saw_discord = 0
            wrote_bot = 0
          }
          /^\[channels_config\.discord\][[:space:]]*$/ {
            in_discord = 1
            saw_discord = 1
            print
            next
          }
          /^\[[^]]+\][[:space:]]*$/ {
            if (in_discord && !wrote_bot) {
              print "bot_token = \"" token "\""
              wrote_bot = 1
            }
            in_discord = 0
            print
            next
          }
          {
            if (in_discord && $0 ~ /^[[:space:]]*bot_token[[:space:]]*=/) {
              print "bot_token = \"" token "\""
              wrote_bot = 1
              next
            }
            print
          }
          END {
            if (in_discord && !wrote_bot) {
              print "bot_token = \"" token "\""
              wrote_bot = 1
            }
            if (!saw_discord) {
              print ""
              print "[channels_config.discord]"
              print "bot_token = \"" token "\""
            }
          }
        ' "$config_file" > "$tmp_file"

        ${pkgs.coreutils}/bin/mv "$tmp_file" "$config_file"
        ${pkgs.coreutils}/bin/chmod 600 "$config_file"
      fi
    fi
  '';

  home.activation.zeroclawRestartService = lib.hm.dag.entryAfter ["reloadSystemd" "zeroclawSyncConfig"] ''
    if [ -f "$HOME/.config/systemd/user/zeroclaw.service" ]; then
      if ${pkgs.systemd}/bin/systemctl --user is-active --quiet zeroclaw.service; then
        ${pkgs.systemd}/bin/systemctl --user restart zeroclaw.service || true
      fi
    fi
  '';
}
