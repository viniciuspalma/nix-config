# Blade-1 USB Recovery Runbook (Sanitized)

This runbook documents the USB-based NixOS recovery flow used for `blade-1`.
It intentionally avoids storing any real passwords, private keys, or public keys.

## Scope

- Target hardware: Raspberry Pi CM4 blade node
- Recovery method: `rpiboot` + USB mass storage + raw image flash from macOS
- Build host for image: `blade-3` (Ubuntu + Nix)

## Security Rules

- Never put real credentials in this file.
- Use placeholders only (example: `<TEMP_PASSWORD>`).
- Do not paste SSH keys in docs.
- Rotate/remove any temporary password auth immediately after recovery.

## Preconditions

1. CM4 is in USB boot mode (`nRPIBOOT/EMMC_DISABLE` jumper fitted).
2. USB cable connected from CM4 to macOS host.
3. `rpiboot` repository/tool available on macOS.
4. `blade-3` reachable over SSH and has Nix available.

## 1) Start USB Boot Mode

From the `usbboot` repo:

```bash
sudo ./rpiboot -d mass-storage-gadget64
```

Wait until second-stage boot finishes and USB disks appear on macOS.

## 2) Identify Disk Mapping Every Session

Always re-check mapping (it can swap between attempts):

```bash
diskutil list
```

Typical outcomes:

- one ~`7.8 GB` disk (CM4 eMMC)
- one ~`1 TB` disk (NVMe SSD)

Never assume disk numbers from previous runs.

## 3) Build CM4-Compatible NixOS Image on Blade-3

Build an aarch64 SD image using NixOS `sd-image-aarch64-installer` module.
Resulting artifact path (example):

```text
/nix/store/<...>-nixos-image-sd-card-<...>-aarch64-linux.img.zst/sd-image/nixos-image-sd-card-<...>-aarch64-linux.img.zst
```

## 4) Flash Image (macOS, streamed from blade-3)

Use this pattern for each target disk (`/dev/rdiskX`):

```bash
diskutil unmountDisk /dev/diskX
ssh vinicius.palma@blade-3 'cat /nix/store/<image-path>.img.zst' \
  | zstd -d \
  | sudo dd of=/dev/rdiskX bs=4M
sync
```

Important:

- Do not use `conv=sync` in this pipeline.
- `bs=4M` was stable in this environment.

## 5) Flash Targets Used in This Recovery

To remove boot-chain ambiguity, image was flashed to both:

- eMMC disk (`~7.8 GB`)
- SSD disk (`~1 TB`)

After writing:

```bash
diskutil eject /dev/disk<eMMC>
diskutil eject /dev/disk<SSD>
```

## 6) Return to Normal Boot

1. Stop `rpiboot` (`Ctrl+C`).
2. Disconnect USB cable.
3. Remove USB boot jumper.
4. Power-cycle via POE.

## 7) Find Host on DHCP

Do not assume prior IP. From `blade-3`:

```bash
nmap -sn 192.168.13.0/24
nmap -Pn -p22 --open 192.168.13.0/24
ip neigh show dev eth0
```

Validate candidate IP:

```bash
ssh <user>@<candidate-ip>
```

## 8) Temporary Access and Hardening

If temporary password auth was used:

1. Login with temporary credential (`<TEMP_PASSWORD>` placeholder).
2. Apply final flake configuration.
3. Re-enable key-only SSH auth.
4. Remove/disable temporary password access.

## Notes

- If host appears in ARP but not in ping scan, still probe SSH directly.
- If node is absent from ARP/DHCP entirely, verify jumper/USB mode status and power cycle.

