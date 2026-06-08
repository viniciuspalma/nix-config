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
  # prompt, e.g.:
  #
  #   op item get <item> --reveal --fields label=password \
  #     | "$(gpgconf --list-dirs libexecdir)/gpg-preset-passphrase" --preset <KEYGRIP>
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
}
