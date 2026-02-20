{lib, ...}: {
  # Shared label-based defaults. Each blade can override as needed.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/writable";
    fsType = "ext4";
  };

  fileSystems."/boot/firmware" = lib.mkDefault {
    device = "/dev/disk/by-label/system-boot";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = lib.mkDefault [];
}
