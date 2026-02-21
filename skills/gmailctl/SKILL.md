---
name: gmailctl
description: Manage Gmail filters on blade hosts using gmailctl CLI. Use when tasks involve reviewing or applying Gmail filter changes, editing ~/.gmailctl/config.jsonnet, initializing OAuth tokens, checking label/filter errors, or validating Gmail automation state. Prefer diff/test before apply and keep credentials out of git-managed paths.
---

# Gmailctl

## Overview

Manage Gmail filters declaratively with `gmailctl` on blade hosts.
Use safe review-first workflow: inspect changes, validate, then apply.

## Workflow

1. Verify auth files exist in `~/.gmailctl/` (`credentials.json`, `token.json`).
2. Review planned changes with `gmailctl diff`.
3. Validate config with `gmailctl test` when needed.
4. Apply with `gmailctl apply` only after confirmation.
5. Re-run `gmailctl diff` to confirm clean state.

## Commands

- `gmailctl diff`
- `gmailctl test`
- `gmailctl apply`
- `gmailctl download`
- `gmailctl init`

## Common Paths

- Config: `~/.gmailctl/config.jsonnet`
- OAuth client: `~/.gmailctl/credentials.json`
- Token cache: `~/.gmailctl/token.json`

## Troubleshooting

- Label not found:
  - Create the label in config or Gmail UI, or remove the label action from the rule.
- OAuth callback on SSH host:
  - Forward the callback port shown by `gmailctl init` using `ssh -L <port>:127.0.0.1:<port> ...`.
- Unexpected apply output:
  - Run `gmailctl diff` and `gmailctl test`, then inspect `config.jsonnet` rule by rule.

## Safety

- Keep credentials and token files only under `~/.gmailctl/`.
- Never commit OAuth credentials or tokens into `nix-config`.
- Use review-first flow (`diff` -> `test` -> `apply`).
