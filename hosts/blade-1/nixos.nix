{
  lib,
  pkgs,
  ...
}: {
  # Raspberry Pi boot loader options were removed in recent nixpkgs.
  # Use extlinux-compatible boot config as the shared default.
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  hardware.enableRedistributableFirmware = true;
}
