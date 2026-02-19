# just is a command runner, Justfile is very similar to Makefile, but simpler.

darwin_hostname := ch-CQTMGK70R5
blade_hostname := blade-1
blade_user := vinicius.palma

############################################################################
#
#  Darwin related commands
#
############################################################################

#  TODO Feel free to remove this target if you don't need a proxy to speed up the build process
darwin-set-proxy:
  sudo python3 scripts/darwin_set_proxy.py

darwin: darwin-set-proxy
  nix build path:.#darwinConfigurations.{{darwin_hostname}}.system \
    --extra-experimental-features 'nix-command flakes'

  ./result/sw/bin/darwin-rebuild switch --flake path:.#{{darwin_hostname}}

darwin-debug: darwin-set-proxy
  nix build path:.#darwinConfigurations.{{darwin_hostname}}.system --show-trace --verbose \
    --extra-experimental-features 'nix-command flakes'

  ./result/sw/bin/darwin-rebuild switch --flake path:.#{{darwin_hostname}} --show-trace --verbose

############################################################################
#
#  Blade related commands (Ubuntu + Home Manager)
#
############################################################################

blade-build:
  nix build 'path:.#homeConfigurations."{{blade_user}}@{{blade_hostname}}".activationPackage' \
    --extra-experimental-features 'nix-command flakes'

blade-switch:
  path=$(nix path-info 'path:.#homeConfigurations."{{blade_user}}@{{blade_hostname}}".activationPackage' \
    --extra-experimental-features 'nix-command flakes'); \
  nix copy --to ssh://{{blade_user}}@{{blade_hostname}} "$path"; \
  ssh {{blade_user}}@{{blade_hostname}} "$path/activate"

############################################################################
#
#  nix related commands
#
############################################################################


update:
  nix flake update

history:
  nix profile history --profile /nix/var/nix/profiles/system

gc:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

  # garbage collect all unused nix store entries
  sudo nix store gc --debug


fmt:
  # format the nix files in this repo
  nix fmt

clean:
  rm -rf result
