# Nix Config: Personal macOS (darwin)

This repository now manages only the local macOS host:

- `ch-CQTMGK70R5` as `nix-darwin` (`aarch64-darwin`)

Blade deployment has been moved to a separate local repository at:

- `~/.config/blades`

## Flake Outputs

- Darwin system:
  - `darwinConfigurations."ch-CQTMGK70R5"`

## Apply on macOS

```bash
nix build path:.#darwinConfigurations.ch-CQTMGK70R5.system \
  --extra-experimental-features 'nix-command flakes'
./result/sw/bin/darwin-rebuild switch --flake path:.#ch-CQTMGK70R5
```

Or use:

```bash
just darwin
```

## Layout

- `hosts/`: local host inventory
- `modules/`: `nix-darwin` system modules
- `home/`: Home Manager user modules for local macOS setup
- `scripts/darwin_set_proxy.py`: optional proxy helper for faster builds
- `Justfile`: darwin helper targets

## Notes

- `path:.#...` is used so local changes are evaluated even before `git add`.
