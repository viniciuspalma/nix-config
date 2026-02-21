{
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

  home.activation.zeroclawSyncTemplateAutonomy = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail

    config_file="$HOME/.zeroclaw/config.toml"
    template_file="$HOME/.zeroclaw/config.template.toml"

    if [ ! -f "$config_file" ] || [ ! -f "$template_file" ]; then
      exit 0
    fi

    autonomy_block_file="$(mktemp)"
    ${pkgs.gawk}/bin/awk '
      /^\[autonomy\][[:space:]]*$/ { in_autonomy = 1 }
      in_autonomy && /^\[[^]]+\][[:space:]]*$/ && $0 !~ /^\[autonomy\][[:space:]]*$/ { exit }
      in_autonomy { print }
    ' "$template_file" > "$autonomy_block_file"

    if [ ! -s "$autonomy_block_file" ]; then
      rm -f "$autonomy_block_file"
      exit 0
    fi

    tmp_file="$(mktemp)"
    ${pkgs.gawk}/bin/awk -v block="$autonomy_block_file" '
      BEGIN { in_autonomy = 0; replaced = 0 }
      /^\[[^]]+\][[:space:]]*$/ {
        if (in_autonomy) {
          in_autonomy = 0
        }
        if ($0 ~ /^\[autonomy\][[:space:]]*$/) {
          while ((getline line < block) > 0) print line
          close(block)
          in_autonomy = 1
          replaced = 1
          next
        }
        print
        next
      }
      {
        if (in_autonomy) next
        print
      }
      END {
        if (!replaced) {
          print ""
          while ((getline line < block) > 0) print line
          close(block)
        }
      }
    ' "$config_file" > "$tmp_file"

    mv "$tmp_file" "$config_file"
    rm -f "$autonomy_block_file"

    ${pkgs.gnused}/bin/sed -i '/^\[channels_config\.discord\]/,/^\[/ s/^mention_only = .*/mention_only = true/' "$config_file"
  '';

  home.activation.zeroclawRestartService = lib.hm.dag.entryAfter ["reloadSystemd" "zeroclawSyncTemplateAutonomy"] ''
    if [ -f "$HOME/.config/systemd/user/zeroclaw.service" ]; then
      if ${pkgs.systemd}/bin/systemctl --user is-active --quiet zeroclaw.service; then
        ${pkgs.systemd}/bin/systemctl --user restart zeroclaw.service || true
      fi
    fi
  '';
}
