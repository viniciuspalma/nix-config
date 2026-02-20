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

- `hosts/`: host inventory and per-host Home Manager modules
- `flake.nix`: output wiring
- `modules/`: `nix-darwin` system modules (macOS only)
- `home/default.nix`: shared Home Manager imports
- `home/core.nix`: Darwin user packages
- `home/core-linux.nix`: Linux blade package profile
- `home/linux.nix`: Home Manager settings for non-NixOS Linux (`targets.genericLinux`)
- `home/fan/`: blade fan scripts + systemd unit (managed outside Nix/Home Manager)
- `Justfile`: helper commands for darwin, blade activation, and fan operations

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
nix run home-manager/master -- switch --flake 'path:.#vinicius.palma@blade-1'
```

Repeat with `blade-2` and `blade-3`.

## Apply a Blade Profile Remotely from macOS

Set target host through `just` variable override:

```bash
just --set blade_hostname blade-1 blade-switch
just --set blade_hostname blade-2 blade-switch
just --set blade_hostname blade-3 blade-switch
```

Sync repo changes to a blade without running Home Manager:

```bash
just --set blade_hostname blade-3 blade-sync
```

`blade-switch` does two things:

1. Syncs your local repo contents (including uncommitted local changes) to `~/.config/nix-config` on the blade.
2. Runs Home Manager switch directly on the blade.

Equivalent raw commands:

```bash
rsync -az --delete --exclude '.git/' --exclude 'result/' ./ vinicius.palma@blade-1:~/.config/nix-config/
ssh vinicius.palma@blade-1 "cd ~/.config/nix-config && nix run home-manager/master -- switch --flake 'path:.#vinicius.palma@blade-1'"
```

## Blade Fan Control (Script-only, outside Nix)

The fan setup is intentionally kept out of Home Manager/Nix builds on blades.
Scripts live in this repo under `home/fan/` and run with system Python packages.

Install on one blade:

```bash
just --set blade_hostname blade-1 fan-install
```

Install on all blades:

```bash
just fan-install-all
```

Useful commands:

```bash
just --set blade_hostname blade-1 blade-sync
just --set blade_hostname blade-1 fan-boost
just --set blade_hostname blade-1 fan-stop
just --set blade_hostname blade-1 fan-status
just --set blade_hostname blade-1 fan-logs
just --set blade_hostname blade-1 fan-read-rpm
just --set blade_hostname blade-1 fan-start
just --set blade_hostname blade-1 --set fan_profile ease_out fan-profile
```

What `fan-install` does:

1. Syncs repo files to `~/.config/nix-config` on the blade.
2. Installs system Python GPIO packages with `apt`.
3. Writes `/etc/fan-control/profile`.
4. Installs `home/fan/fan-control.service` to `/etc/systemd/system/fan-control.service`.
5. Enables and starts the service.

Default tuning in `home/fan/fan_control.py` is intentionally aggressive:

- `OFF_TEMP=35`
- `MIN_TEMP=40`
- `MAX_TEMP=60`
- minimum running duty `35%` when fan is on

Hardware note:

- Only the blade in Port A/J1 can drive PWM fan speed.
- Other blades can read tach RPM only.
- If `fan-control.service` is running on a host, `fan-read-rpm` on that same host may fail with `GPIO busy`.
  - Either run `fan-read-rpm` from another blade.
  - Or stop/start control service around RPM reads: `fan-stop` -> `fan-read-rpm` -> `fan-start`.

## General Notes

- `path:.#...` is used so local changes are evaluated even before `git add`.
- Blade networking is DHCP-first in this setup.
- Keep `blade-1/2/3` identical initially except hardware-role overrides (Port A/J1 controls PWM; others are read-only for fan tach).
