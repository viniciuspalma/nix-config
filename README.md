# Nix Config: macOS + Ubuntu Blades

This repository manages:

- `ch-CQTMGK70R5` as `nix-darwin` (`aarch64-darwin`)
- `blade-1`, `blade-2`, `blade-3` as Ubuntu hosts with standalone Home Manager (`aarch64-linux`)

The blade hosts intentionally avoid macOS-only settings/apps.

## Flake Outputs

- Darwin system:
  - `darwinConfigurations."ch-CQTMGK70R5"`
- Blade Home Manager profiles:
  - `homeConfigurations."vinicius.palma@blade-1"`
  - `homeConfigurations."vinicius.palma@blade-2"`
  - `homeConfigurations."vinicius.palma@blade-3"`

## Which rebuild command to use

- `nixos-rebuild`: only for NixOS (`nixosConfigurations`), not used by these Ubuntu blades
- `darwin-rebuild`: for macOS host (`darwinConfigurations`)
- `home-manager switch`: for Ubuntu blades (`homeConfigurations`)

## Layout

- `flake.nix`: host inventory and output wiring
- `modules/`: `nix-darwin` system modules (macOS only)
- `home/default.nix`: shared + platform-specific Home Manager imports
- `home/core.nix`: Darwin user packages
- `home/core-linux.nix`: Linux blade package profile
- `home/linux.nix`: Home Manager settings for non-NixOS Linux (`targets.genericLinux`)
- `home/fan-control.nix`: fan package and script wiring for blades
- `home/fan/`: fan control script, tach script, and systemd service template
- `Justfile`: helper commands for darwin, blades, and fan operations

## Apply on macOS (local host)

```bash
nix build path:.#darwinConfigurations.ch-CQTMGK70R5.system \
  --extra-experimental-features 'nix-command flakes'
./result/sw/bin/darwin-rebuild switch --flake path:.#ch-CQTMGK70R5
```

Or use:

```bash
just darwin
```

## Bootstrap a Blade (Ubuntu)

Run on each blade host (replace hostname accordingly):

```bash
ssh vinicius.palma@blade-1
git clone <your-repo-url> ~/.config/nix-config
cd ~/.config/nix-config
nix run home-manager/master -- switch --flake 'path:.#"vinicius.palma@blade-1"'
```

Repeat with `blade-2` and `blade-3`.

## Apply a Blade Profile Remotely from macOS

Set target host through `just` variable override:

```bash
just --set blade_hostname blade-1 blade-switch
just --set blade_hostname blade-2 blade-switch
just --set blade_hostname blade-3 blade-switch
```

Equivalent raw commands:

```bash
path=$(nix path-info 'path:.#homeConfigurations."vinicius.palma@blade-1".activationPackage' \
  --extra-experimental-features 'nix-command flakes')
nix copy --to ssh://vinicius.palma@blade-1 "$path"
ssh vinicius.palma@blade-1 "$path/activate"
```

## Fan Control on Blades

### Host roles

- `blade-1`: PWM control + RPM read
- `blade-2`: PWM control + RPM read
- `blade-3`: RPM read only (no PWM control service)

### What gets installed by Home Manager

- `~/.config/fan-control/fan_control.py` on controller hosts
- `~/.config/fan-control/read_fan_speed.py` on all blades
- `~/.config/fan-control/fan-control.service` on controller hosts
- Binaries in `~/.nix-profile/bin`:
  - `fan-control-service` (controller hosts)
  - `fan-read-rpm` (all blades)

### Controller setup (`blade-1` and `blade-2`)

After `blade-switch`, install and start systemd service:

```bash
just --set blade_hostname blade-1 fan-install-service
just --set blade_hostname blade-1 fan-enable
```

Repeat on `blade-2`.

### Configure fan curve profile

Available profiles: `linear`, `ease_in`, `ease_out`, `ease_in_out`

```bash
just --set blade_hostname blade-1 --set fan_profile ease_out fan-set-profile
just --set blade_hostname blade-2 --set fan_profile ease_out fan-set-profile
```

### Monitor and troubleshoot

```bash
just --set blade_hostname blade-1 fan-status
just --set blade_hostname blade-1 fan-logs
just --set blade_hostname blade-1 fan-read-rpm
```

For `blade-3` (read-only):

```bash
just --set blade_hostname blade-3 fan-read-rpm
```

### Notes

- Compute Blade PWM control should run only on the PWM-capable nodes you mapped (`blade-1` and `blade-2`).
- `blade-3` is intentionally read-only in this setup.
- Service profile file path is `/etc/fan-control/profile`.
- `fan-install-service` will fail on read-only hosts by design.

## General Notes

- `path:.#...` is used so local changes are evaluated even before `git add`.
- Blade networking is DHCP-first in this setup.
- Keep `blade-1/2/3` identical initially except hardware-role overrides (fan control vs read-only).
