# TOOLS.md

## Environment Notes

- Nix-managed profile state path: `~/.openclaw-<profile>/`
- Current profile: `blade-2`
- Service: `openclaw-gateway.service` (systemd user unit)
- Agent identity: Devi (`visionary-devi`) for `code-visionary`
- GitHub org: `code-visionary`
- Coding backend agent: `coder` (`openai-codex/gpt-5.3-codex`)
- Codex CLI binary: `codex` (installed from `numtide/llm-agents.nix`)

## Operational Commands

- Service status: `systemctl --user status openclaw-gateway.service --no-pager`
- Live logs: `journalctl --user -u openclaw-gateway.service -f`
- Config source of truth: `~/.config/nix-config/home/openclaw/openclaw.template.json`
- Sentry triage context: use `SENTRY_AUTH_TOKEN` from `~/.openclaw-blade-2/.env`
- GitHub issue context: org `code-visionary`, user `visionary-devi`
- Codex check: `codex --version`
- OpenClaw model/auth check: `openclaw --profile blade-2 models status --probe`
- Codex non-interactive run: `codex exec "your task here"`

## Main Repositories (quick reference)

- https://github.com/code-visionary/dgas-api
- https://github.com/code-visionary/dgas-mobile
- https://github.com/code-visionary/dapp-admin
- https://github.com/code-visionary/dapp-tracker
- https://github.com/code-visionary/code-visionary-web
- https://github.com/code-visionary/dreamia-api
- https://github.com/code-visionary/dreamia-web
- https://github.com/code-visionary/dreamia-mobile
- https://github.com/code-visionary/dreamia-android
- https://github.com/code-visionary/iac-gcloud
- https://github.com/code-visionary/iac-cloudflare
- https://github.com/code-visionary/docs

## Search Alias Rule

- `dapp` (current) == `dgas` (legacy).
- For investigations, search both keywords (`dapp` and `dgas`) in code, issues, PRs, and Sentry context.
