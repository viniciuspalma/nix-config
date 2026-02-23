#!/usr/bin/env bash
set -euo pipefail

conf_file="${1:?usage: apply_blade_nix_daemon_conf.sh <conf_file> <trusted_user>}"
trusted_user="${2:?usage: apply_blade_nix_daemon_conf.sh <conf_file> <trusted_user>}"

if [ ! -f "$conf_file" ]; then
  echo "ERROR: config file not found: $conf_file" >&2
  exit 1
fi

sudo mkdir -p /etc/nix
sudo touch /etc/nix/nix.conf

while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  line="$(printf '%s' "$raw_line" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
  if [ -z "$line" ] || [ "${line#\#}" != "$line" ]; then
    continue
  fi

  if ! sudo grep -Fqx "$line" /etc/nix/nix.conf; then
    printf '%s\n' "$line" | sudo tee -a /etc/nix/nix.conf >/dev/null
  fi
done < "$conf_file"

if ! sudo grep -Eq "^[[:space:]]*extra-trusted-users[[:space:]]*=.*(^|[[:space:]])${trusted_user}([[:space:]]|$)" /etc/nix/nix.conf; then
  printf 'extra-trusted-users = %s\n' "$trusted_user" | sudo tee -a /etc/nix/nix.conf >/dev/null
fi

sudo systemctl restart nix-daemon.service
