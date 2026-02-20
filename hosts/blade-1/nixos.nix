{
  lib,
  pkgs,
  ...
}: {
  # Raspberry Pi boot loader options were removed in recent nixpkgs.
  # Keep extlinux on the firmware partition and provision Pi firmware/U-Boot explicitly.
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.mirroredBoots = [
    {
      path = "/boot/firmware";
    }
  ];
  boot.kernelPackages = pkgs.linuxPackages_rpi4;

  hardware.enableRedistributableFirmware = true;

  system.activationScripts.raspberryPiFirmware = {
    text = ''
      if [ ! -d /boot/firmware ]; then
        echo "warning: /boot/firmware not mounted; skipping Raspberry Pi firmware update" >&2
        exit 0
      fi

      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bootcode.bin /boot/firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/fixup*.dat /boot/firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/start*.elf /boot/firmware/

      cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin /boot/firmware/u-boot-rpi4.bin
      cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin /boot/firmware/armstub8-gic.bin

      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb /boot/firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb /boot/firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb /boot/firmware/
      cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4s.dtb /boot/firmware/

      cat > /boot/firmware/config.txt <<'EOF'
      [pi4]
      kernel=u-boot-rpi4.bin
      enable_gic=1
      armstub=armstub8-gic.bin
      disable_overscan=1
      arm_boost=1

      [cm4]
      otg_mode=1

      [all]
      arm_64bit=1
      enable_uart=1
      avoid_warnings=1
      EOF
    '';
  };
}
