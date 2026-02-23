{
  config,
  lib,
  pkgs,
  llmAgents,
  self,
  hostname ? "default",
  ...
}: let
  profile = lib.toLower (lib.replaceStrings [" "] ["-"] hostname);
  stateDirRelative = ".openclaw-${profile}";
  stateDir = "${config.home.homeDirectory}/${stateDirRelative}";
  configPath = "${stateDir}/openclaw.json";
  serviceEnv = ''
    [Service]
    Environment="PATH=${config.home.homeDirectory}/.nix-profile/bin:${config.home.homeDirectory}/.local/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
    Environment="SHELL=/bin/bash"
    Environment="OPENCLAW_NIX_MODE=1"
    Environment="OPENCLAW_LOAD_SHELL_ENV=1"
    Environment="OPENCLAW_PROFILE=${profile}"
    Environment="OPENCLAW_STATE_DIR=%h/${stateDirRelative}"
    Environment="OPENCLAW_CONFIG_PATH=%h/${stateDirRelative}/openclaw.json"
    EnvironmentFile=-%h/${stateDirRelative}/.env
  '';
in {
  home.packages = [
    (lib.hiPrio self.packages.${pkgs.system}.openclaw)
    (lib.hiPrio llmAgents.packages.${pkgs.system}.codex)
    pkgs.sqlite
  ];

  home.shellAliases = {
    oc = "OPENCLAW_PROFILE=${profile} openclaw --profile ${profile}";
  };

  home.sessionVariables = {
    OPENCLAW_NIX_MODE = "1";
    OPENCLAW_LOAD_SHELL_ENV = "1";
    OPENCLAW_PROFILE = profile;
    OPENCLAW_STATE_DIR = stateDir;
    OPENCLAW_CONFIG_PATH = configPath;
  };

  home.file."${stateDirRelative}/openclaw.template.json".source = ./openclaw/openclaw.template.json;
  home.file."${stateDirRelative}/workspace/AGENTS.md" = {
    source = ./openclaw/workspace/AGENTS.md;
    force = true;
  };
  home.file."${stateDirRelative}/workspace/SOUL.md" = {
    source = ./openclaw/workspace/SOUL.md;
    force = true;
  };
  home.file."${stateDirRelative}/workspace/IDENTITY.md" = {
    source = ./openclaw/workspace/IDENTITY.md;
    force = true;
  };
  home.file."${stateDirRelative}/workspace/USER.md" = {
    source = ./openclaw/workspace/USER.md;
    force = true;
  };
  home.file."${stateDirRelative}/workspace/TOOLS.md" = {
    source = ./openclaw/workspace/TOOLS.md;
    force = true;
  };
  home.file."${stateDirRelative}/workspace/HEARTBEAT.md" = {
    source = ./openclaw/workspace/HEARTBEAT.md;
    force = true;
  };
  home.file."${stateDirRelative}/workspace/skills/gmailctl".source = ../skills/gmailctl;
  home.file."${stateDirRelative}/workspace/skills/sentry".source = ../skills/sentry;

  systemd.user.services."openclaw-gateway" = {
    Unit = {
      Description = "OpenClaw Gateway";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${self.packages.${pkgs.system}.openclaw}/bin/openclaw --profile ${profile} gateway";
      Restart = "always";
      RestartSec = "3s";
      WorkingDirectory = stateDir;
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };

  home.file.".config/systemd/user/openclaw-gateway.service.d/10-environment.conf".text = serviceEnv;

  home.activation.openclawSyncConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    set -euo pipefail

    profile="${profile}"
    config_dir="$HOME/.openclaw-$profile"
    template_file="$config_dir/openclaw.template.json"
    config_file="$config_dir/openclaw.json"
    workspace_dir="$config_dir/workspace"
    secrets_dir="$config_dir/secrets"
    env_file="$config_dir/.env"

    ${pkgs.coreutils}/bin/mkdir -p "$config_dir" "$workspace_dir" "$secrets_dir"

    if [ -f "$template_file" ]; then
      ${pkgs.coreutils}/bin/install -m 600 "$template_file" "$config_file"
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$config_dir/agents/main/sessions" "$config_dir/credentials"
    ${pkgs.coreutils}/bin/rm -f "$workspace_dir/BOOTSTRAP.md"

    read_secret() {
      secret_file="$1"
      if [ -f "$secret_file" ]; then
        ${pkgs.coreutils}/bin/tr -d '\r\n' < "$secret_file"
      fi
    }

    discord_token="$(read_secret "$secrets_dir/discord_bot_token")"
    anthropic_key="$(read_secret "$secrets_dir/anthropic_api_key")"
    openai_key="$(read_secret "$secrets_dir/openai_api_key")"
    gemini_key="$(read_secret "$secrets_dir/gemini_api_key")"
    sentry_token="$(read_secret "$secrets_dir/sentry_auth_token")"
    sentry_base_url="$(read_secret "$secrets_dir/sentry_base_url")"
    gateway_token_file="$secrets_dir/gateway_token"
    hooks_token_file="$secrets_dir/hooks_token"

    if [ ! -s "$gateway_token_file" ]; then
      ${pkgs.openssl}/bin/openssl rand -hex 32 > "$gateway_token_file"
      ${pkgs.coreutils}/bin/chmod 600 "$gateway_token_file"
    fi

    if [ ! -s "$hooks_token_file" ]; then
      ${pkgs.openssl}/bin/openssl rand -hex 32 > "$hooks_token_file"
      ${pkgs.coreutils}/bin/chmod 600 "$hooks_token_file"
    fi

    gateway_token="$(read_secret "$gateway_token_file")"
    hooks_token="$(read_secret "$hooks_token_file")"

    tmp_file="$(mktemp)"
    {
      printf 'OPENCLAW_PROFILE=%s\n' "$profile"
      printf 'OPENCLAW_STATE_DIR=%s\n' "$config_dir"
      printf 'OPENCLAW_CONFIG_PATH=%s\n' "$config_file"
      printf 'OPENCLAW_NIX_MODE=1\n'
      printf 'OPENCLAW_LOAD_SHELL_ENV=1\n'
      if [ -n "$discord_token" ]; then
        printf 'DISCORD_BOT_TOKEN=%s\n' "$discord_token"
      fi
      if [ -n "$anthropic_key" ]; then
        printf 'ANTHROPIC_API_KEY=%s\n' "$anthropic_key"
      fi
      if [ -n "$openai_key" ]; then
        printf 'OPENAI_API_KEY=%s\n' "$openai_key"
      fi
      if [ -n "$gemini_key" ]; then
        printf 'GEMINI_API_KEY=%s\n' "$gemini_key"
      fi
      if [ -n "$sentry_token" ]; then
        printf 'SENTRY_AUTH_TOKEN=%s\n' "$sentry_token"
        printf 'SENTRY_ORG=code-visionary\n'
      fi
      if [ -n "$sentry_base_url" ]; then
        printf 'SENTRY_BASE_URL=%s\n' "$sentry_base_url"
      fi
      if [ -n "$gateway_token" ]; then
        printf 'OPENCLAW_GATEWAY_TOKEN=%s\n' "$gateway_token"
      fi
      if [ -n "$hooks_token" ]; then
        printf 'OPENCLAW_HOOKS_TOKEN=%s\n' "$hooks_token"
      fi
    } > "$tmp_file"

    ${pkgs.coreutils}/bin/mv "$tmp_file" "$env_file"
    ${pkgs.coreutils}/bin/chmod 600 "$env_file"
  '';

  home.activation.openclawCleanupZeroclaw = lib.hm.dag.entryAfter ["reloadSystemd"] ''
    set -euo pipefail

    ${pkgs.systemd}/bin/systemctl --user stop zeroclaw.service >/dev/null 2>&1 || true
    ${pkgs.systemd}/bin/systemctl --user disable zeroclaw.service >/dev/null 2>&1 || true
    ${pkgs.systemd}/bin/systemctl --user reset-failed zeroclaw.service >/dev/null 2>&1 || true

    ${pkgs.coreutils}/bin/rm -rf "$HOME/.config/systemd/user/zeroclaw.service"
    ${pkgs.coreutils}/bin/rm -rf "$HOME/.config/systemd/user/zeroclaw.service.d"
    ${pkgs.coreutils}/bin/rm -rf "$HOME/.zeroclaw"

    ${pkgs.systemd}/bin/systemctl --user daemon-reload >/dev/null 2>&1 || true
  '';

  home.activation.openclawRestartService = lib.hm.dag.entryAfter ["reloadSystemd" "openclawSyncConfig"] ''
    for service in "openclaw-gateway.service"; do
      if ${pkgs.systemd}/bin/systemctl --user is-active --quiet "$service"; then
        ${pkgs.systemd}/bin/systemctl --user restart "$service" || true
      fi
    done
  '';
}
