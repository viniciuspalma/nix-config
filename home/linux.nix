{
  lib,
  isNixOS ? false,
  ...
}: {
  # Enable Home Manager integration only for non-NixOS Linux distributions.
  targets.genericLinux.enable = lib.mkDefault (!isNixOS);
}
