---
name: "sentry"
description: "Use when the user asks to inspect Sentry issues or events, summarize production errors, or pull Sentry health data for Code Visionary services; perform read-only queries with the bundled script, require `SENTRY_AUTH_TOKEN`, and choose project from the approved list based on request context."
---


# Sentry (Read-only Observability)

## Quick start

- If not already authenticated, ask the user to provide a valid `SENTRY_AUTH_TOKEN` (read-only scopes such as `project:read`, `event:read`) or to log in and create one before running commands.
- Set `SENTRY_AUTH_TOKEN` as an env var.
- Org is fixed to `code-visionary`.
- Do not rely on `SENTRY_PROJECT` env var; always select `--project` from the project list below using request context.
- API base URL defaults to `https://sentry.io` for Sentry SaaS.
- `https://code-visionary.sentry.io` is the UI host; do not use it as the API base URL.
- Optional override: `SENTRY_BASE_URL` (for region/self-hosted only, e.g. `https://us.sentry.io`, `https://de.sentry.io`, or your self-hosted domain).
- Defaults: time range `24h`, environment `prod`, limit 20 (max 50).
- Always call the Sentry API (no heuristics, no caching).

If the token is missing, give the user these steps:
1. Create a Sentry auth token: https://sentry.io/settings/account/api/auth-tokens/
2. Create a token with read-only scopes such as `project:read`, `event:read`, and `org:read`.
3. Set `SENTRY_AUTH_TOKEN` as an environment variable in their system.
4. Offer to guide them through setting the environment variable for their OS/shell if needed.
- Never ask the user to paste the full token in chat. Ask them to set it locally and confirm when ready.

## Approved projects (context-driven selection)

Use one project per query unless the user explicitly asks for a cross-project sweep.

- `admin-dapp`: API administrative repo (`dgas-api`) / internal admin flows.
- `dapp-admin`: UI react-router repo (`dapp-admin`).
- `dgas-api`: API customer repo (`dgas-api`) / customer-facing API flows.
- `code-visionary-web`: organization landing page react-router repo (`code-visionary-web`).
- `dapp-tracker`: Rust location tracking API repo (`dapp-tracker`).
- `dreamia-web`: Dreamia web application NextJS repo (`dreamia-web`).

Selection rules:
1. If user names a project explicitly, use that exact project.
2. If request references repo/service names, map to the project list above.
3. If request only says `dgas-api`, use `admin-dapp` for admin/internal context and `dgas-api` for customer/public context.
4. If still ambiguous, ask one clarification question before querying.

## Core tasks (use bundled script)

Use `scripts/sentry_api.py` for deterministic API calls. It handles pagination and retries once on transient errors.

## Skill path (set once)

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export SENTRY_API="$CODEX_HOME/skills/sentry/scripts/sentry_api.py"
```

User-scoped skills install under `$CODEX_HOME/skills` (default: `~/.codex/skills`).

### 1) List issues (ordered by most recent)

```bash
python3 "$SENTRY_API" \
  list-issues \
  --org code-visionary \
  --project {project-from-context} \
  --environment prod \
  --time-range 24h \
  --limit 20 \
  --query "is:unresolved"
```

### 2) Resolve an issue short ID to issue ID

```bash
python3 "$SENTRY_API" \
  list-issues \
  --org code-visionary \
  --project {project-from-context} \
  --query "ABC-123" \
  --limit 1
```

Use the returned `id` for issue detail or events.

### 3) Issue detail

```bash
python3 "$SENTRY_API" \
  issue-detail \
  1234567890
```

### 4) Issue events

```bash
python3 "$SENTRY_API" \
  issue-events \
  1234567890 \
  --limit 20
```

### 5) Event detail (no stack traces by default)

```bash
python3 "$SENTRY_API" \
  event-detail \
  --org code-visionary \
  --project {project-from-context} \
  abcdef1234567890
```

## API requirements

Always use these endpoints (GET only):

- List issues: `/api/0/projects/{org_slug}/{project_slug}/issues/`
- Issue detail: `/api/0/issues/{issue_id}/`
- Events for issue: `/api/0/issues/{issue_id}/events/`
- Event detail: `/api/0/projects/{org_slug}/{project_slug}/events/{event_id}/`

## Inputs and defaults

- `org_slug`: fixed to `code-visionary`.
- `project_slug`: choose from approved project list using request context.
- `time_range`: default `24h` (pass as `statsPeriod`).
- `environment`: default `prod`.
- `limit`: default 20, max 50 (paginate until limit reached).
- `search_query`: optional `query` parameter.
- `issue_short_id`: resolve via list-issues query first.

## Output formatting rules

- Issue list: show title, short_id, status, first_seen, last_seen, count, environments, top_tags; order by most recent.
- Event detail: include culprit, timestamp, environment, release, url.
- If no results, state explicitly.
- Redact PII in output (emails, IPs). Do not print raw stack traces.
- Never echo auth tokens.

## Golden test inputs

- Org: `code-visionary`
- Project: one of `admin-dapp`, `dapp-admin`, `dgas-api`, `code-visionary-web`, `dapp-tracker`, `dreamia-web`
- Issue short ID: `{ABC-123}`

Example prompt: “List the top 10 open issues for prod in the last 24h.”
Expected: ordered list with titles, short IDs, counts, last seen.
