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

## Layout

- `flake.nix`: host inventory and output wiring
- `modules/`: `nix-darwin` system modules (macOS only)
- `home/default.nix`: shared + platform-specific Home Manager imports
- `home/core.nix`: Darwin user packages
- `home/core-linux.nix`: Linux blade package profile
- `home/linux.nix`: Home Manager settings for non-NixOS Linux (`targets.genericLinux`)
- `Justfile`: helper commands for darwin rebuild and blade activation

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

## Notes

- `path:.#...` is used so local changes are evaluated even before `git add`.
- Blade networking is DHCP-first in this setup.
- Keep `blade-1/2/3` identical initially; add per-host overrides later if needed.
