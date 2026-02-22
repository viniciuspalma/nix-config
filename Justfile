# just is a command runner, Justfile is very similar to Makefile, but simpler.

darwin_hostname := "ch-CQTMGK70R5"
blade_hostname := "blade-2"
blade_user := "vinicius.palma"
fan_profile := "ease_out"
op_account := "my.1password.com"
op_environment := "gbzbzblosaqcyxr2bg7bd7ewna"
blade_nix_bin := "/nix/var/nix/profiles/default/bin/nix"
blade_nix_bin_dir := "/nix/var/nix/profiles/default/bin"

############################################################################
#
#  Darwin related commands
#
############################################################################

#  TODO Feel free to remove this target if you don't need a proxy to speed up the build process
darwin-set-proxy:
  sudo python3 scripts/darwin_set_proxy.py

darwin: darwin-set-proxy
  nix build path:.#darwinConfigurations.{{darwin_hostname}}.system \
    --extra-experimental-features 'nix-command flakes'

  ./result/sw/bin/darwin-rebuild switch --flake path:.#{{darwin_hostname}}

darwin-debug: darwin-set-proxy
  nix build path:.#darwinConfigurations.{{darwin_hostname}}.system --show-trace --verbose \
    --extra-experimental-features 'nix-command flakes'

  ./result/sw/bin/darwin-rebuild switch --flake path:.#{{darwin_hostname}} --show-trace --verbose

############################################################################
#
#  Blade related commands (Ubuntu + Home Manager)
#
############################################################################

blade-build:
  nix build 'path:.#homeConfigurations."{{blade_user}}@{{blade_hostname}}".activationPackage' \
    --extra-experimental-features 'nix-command flakes'

blade-sync:
  ssh {{blade_user}}@{{blade_hostname}} 'mkdir -p ~/.config/nix-config'
  rsync -az --delete \
    --exclude '.git/' \
    --exclude 'result/' \
    ./ {{blade_user}}@{{blade_hostname}}:~/.config/nix-config/

blade-sync-openclaw-secret:
  if [ -z "${DISCORD_BOT_TOKEN:-}" ]; then \
    echo "ERROR: missing DISCORD_BOT_TOKEN in environment."; \
    exit 1; \
  fi
  if [ -z "${ANTHROPIC_API_KEY:-}" ]; then \
    echo "ERROR: missing ANTHROPIC_API_KEY in environment."; \
    exit 1; \
  fi
  if [ -z "${SENTRY_AUTH_TOKEN:-}" ]; then \
    echo "ERROR: missing SENTRY_AUTH_TOKEN in environment."; \
    exit 1; \
  fi
  printf '%s' "$DISCORD_BOT_TOKEN" | ssh {{blade_user}}@{{blade_hostname}} 'umask 077; mkdir -p ~/.openclaw-{{blade_hostname}}/secrets && cat > ~/.openclaw-{{blade_hostname}}/secrets/discord_bot_token'
  printf '%s' "$ANTHROPIC_API_KEY" | ssh {{blade_user}}@{{blade_hostname}} 'umask 077; mkdir -p ~/.openclaw-{{blade_hostname}}/secrets && cat > ~/.openclaw-{{blade_hostname}}/secrets/anthropic_api_key'
  if [ -n "${OPENAI_API_KEY:-}" ]; then printf '%s' "$OPENAI_API_KEY" | ssh {{blade_user}}@{{blade_hostname}} 'umask 077; mkdir -p ~/.openclaw-{{blade_hostname}}/secrets && cat > ~/.openclaw-{{blade_hostname}}/secrets/openai_api_key'; else ssh {{blade_user}}@{{blade_hostname}} 'rm -f ~/.openclaw-{{blade_hostname}}/secrets/openai_api_key'; fi
  printf '%s' "$SENTRY_AUTH_TOKEN" | ssh {{blade_user}}@{{blade_hostname}} 'umask 077; mkdir -p ~/.openclaw-{{blade_hostname}}/secrets && cat > ~/.openclaw-{{blade_hostname}}/secrets/sentry_auth_token'
  if [ -n "${SENTRY_BASE_URL:-}" ]; then printf '%s' "$SENTRY_BASE_URL" | ssh {{blade_user}}@{{blade_hostname}} 'umask 077; mkdir -p ~/.openclaw-{{blade_hostname}}/secrets && cat > ~/.openclaw-{{blade_hostname}}/secrets/sentry_base_url'; fi

blade-switch: blade-sync blade-sync-openclaw-secret
  ssh {{blade_user}}@{{blade_hostname}} "export PATH={{blade_nix_bin_dir}}:\$PATH; cd ~/.config/nix-config && {{blade_nix_bin}} run home-manager/master -- switch --flake 'path:.#{{blade_user}}@{{blade_hostname}}'"

blade-switch-all:
  for host in blade-2 blade-3; do \
    just --set blade_hostname "$host" blade-switch; \
  done

blade-switch-op:
  op run --account {{op_account}} --environment {{op_environment}} -- just --set blade_hostname "{{blade_hostname}}" blade-switch

blade-switch-all-op:
  op run --account {{op_account}} --environment {{op_environment}} -- just blade-switch-all

blade-openclaw-build: blade-sync
  ssh {{blade_user}}@{{blade_hostname}} "cd ~/.config/nix-config && {{blade_nix_bin}} build 'path:.#packages.aarch64-linux.openclaw' --extra-experimental-features 'nix-command flakes'"

blade-openclaw-run: blade-sync
  ssh {{blade_user}}@{{blade_hostname}} "cd ~/.config/nix-config && OPENCLAW_PROFILE={{blade_hostname}} {{blade_nix_bin}} run 'path:.#openclaw' -- --help"

############################################################################
#
#  Blade fan control (script-only; outside Home Manager)
#
############################################################################

fan-install: blade-sync
  ssh {{blade_user}}@{{blade_hostname}} 'sudo apt-get update'
  ssh {{blade_user}}@{{blade_hostname}} 'sudo apt-get install -y python3-gpiozero'
  ssh {{blade_user}}@{{blade_hostname}} 'sudo apt-get install -y python3-rpi.gpio || true'
  ssh {{blade_user}}@{{blade_hostname}} 'sudo apt-get install -y python3-lgpio || true'
  ssh {{blade_user}}@{{blade_hostname}} 'sudo mkdir -p /etc/fan-control'
  ssh {{blade_user}}@{{blade_hostname}} "echo {{fan_profile}} | sudo tee /etc/fan-control/profile >/dev/null"
  ssh {{blade_user}}@{{blade_hostname}} 'sudo install -m 0644 ~/.config/nix-config/home/fan/fan-control.service /etc/systemd/system/fan-control.service'
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl daemon-reload'
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl enable --now fan-control.service'

fan-profile:
  ssh {{blade_user}}@{{blade_hostname}} "echo {{fan_profile}} | sudo tee /etc/fan-control/profile >/dev/null"
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl restart fan-control.service'

fan-boost:
  ssh {{blade_user}}@{{blade_hostname}} "echo ease_out | sudo tee /etc/fan-control/profile >/dev/null"
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl restart fan-control.service'

fan-start:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl start fan-control.service'

fan-stop:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl stop fan-control.service'

fan-status:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl status fan-control.service --no-pager'

fan-logs:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo journalctl -u fan-control.service -n 100 --no-pager'

fan-read-rpm:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo python3 -u ~/.config/nix-config/home/fan/read_fan_speed.py'

fan-install-all:
  for host in blade-2 blade-3; do \
    just --set blade_hostname "$host" fan-install; \
  done

############################################################################
#
#  nix related commands
#
############################################################################


update:
  nix flake update

history:
  nix profile history --profile /nix/var/nix/profiles/system

gc:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

  # garbage collect all unused nix store entries
  sudo nix store gc --debug


fmt:
  # format the nix files in this repo
  nix fmt

clean:
  rm -rf result
