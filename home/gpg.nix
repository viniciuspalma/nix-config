{
  lib,
  pkgs,
  ...
}: {
  # Declaratively manage ~/.gnupg/gpg-agent.conf.
  #
  # `allow-preset-passphrase` lets the `gpg-preset-passphrase` helper push a
  # passphrase straight into gpg-agent's cache (keyed by keygrip). We use it to
  # feed the GPG signing key's passphrase from 1Password without a pinentry
  # prompt (see the gpg_cache shell function below).
  #
  # The cache TTLs keep that preset alive long enough for non-interactive
  # signing (matches the 2h/24h gpg defaults explicitly so they're not silently
  # shortened by a future gpg release).
  home.file.".gnupg/gpg-agent.conf".text = ''
    allow-preset-passphrase
    default-cache-ttl 7200
    max-cache-ttl 86400
  '';

  # The running gpg-agent caches its config in memory: a freshly-changed
  # gpg-agent.conf only takes effect once the agent re-reads it. Without this,
  # editing the conf leaves a stale agent that still answers PRESET_PASSPHRASE
  # with "Not supported". Killing it on every switch forces the next gpg call to
  # spawn a fresh agent with the current config.
  home.activation.reloadGpgAgent =
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent || true
    '';

  # `gpg_cache`: load the signing key's passphrase from 1Password into
  # gpg-agent so commit signing never prompts. The passphrase then lives in the
  # agent for max-cache-ttl (24h above), shared across every terminal.
  #
  # It only calls 1Password when the key is NOT already cached, so running it on
  # every interactive shell startup is an instant no-op once primed — 1Password
  # is only hit after a reboot, an agent restart, or once the 24h TTL lapses.
  #
  # NOTE: GPG_KEYGRIP / OP_ITEM below are this machine's values. Re-derive the
  # keygrip with `gpg --list-secret-keys --with-keygrip` if the key changes.
  programs.zsh.initContent = lib.mkAfter ''
    gpg_cache() {
      local GPG_KEYGRIP=ACB12F423A6647EC65BDA93DA8CBE4932739306C
      local OP_ITEM=dlasat2miytjixyya3xsglghxa

      command -v op >/dev/null 2>&1 || return 0
      gpgconf --launch gpg-agent 2>/dev/null

      # Already cached? KEYINFO field 7 is "1" when the passphrase is held.
      if gpg-connect-agent "keyinfo $GPG_KEYGRIP" /bye 2>/dev/null \
           | awk '$1=="S" && $2=="KEYINFO" && $7=="1" {hit=1} END {exit hit?0:1}'; then
        return 0
      fi

      op item get "$OP_ITEM" --reveal --fields label=password \
        | "$(gpgconf --list-dirs libexecdir)/gpg-preset-passphrase" --preset "$GPG_KEYGRIP"
    }

    # Prime on interactive shell startup. Instant when already cached; only the
    # first shell after a reboot/expiry hits 1Password (may show a prompt).
    # Delete this block if you'd rather run `gpg_cache` on demand only.
    if [[ -o interactive ]]; then
      gpg_cache 2>/dev/null
    fi
  '';
}
