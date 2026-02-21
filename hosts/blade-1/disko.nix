{
  ...
}: {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          system-boot = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              extraArgs = [ "-n" "system-boot" ];
              mountpoint = "/boot/firmware";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          writable = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              extraArgs = [ "-L" "writable" ];
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
