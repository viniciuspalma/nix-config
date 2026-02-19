# just is a command runner, Justfile is very similar to Makefile, but simpler.

darwin_hostname := "ch-CQTMGK70R5"
blade_hostname := "blade-1"
blade_user := "vinicius.palma"
fan_profile := "linear"

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
  rsync -az --delete \
    --exclude '.git/' \
    --exclude 'result/' \
    ./ {{blade_user}}@{{blade_hostname}}:~/.config/nix-config/
  ssh {{blade_user}}@{{blade_hostname}} "cd ~/.config/nix-config && nix run home-manager/master -- switch --flake 'path:.#\"{{blade_user}}@{{blade_hostname}}\"'"

############################################################################
#
#  Blade fan control commands
#
############################################################################

fan-role:
  ssh {{blade_user}}@{{blade_hostname}} 'if [ -f ~/.config/fan-control/fan-control.service ]; then echo controller; else echo read-only; fi'

fan-install-service:
  ssh {{blade_user}}@{{blade_hostname}} 'if [ ! -f ~/.config/fan-control/fan-control.service ]; then echo "fan control service is not available on this host"; exit 1; fi; sudo install -Dm644 ~/.config/fan-control/fan-control.service /etc/systemd/system/fan-control.service; sudo mkdir -p /etc/fan-control; sudo systemctl daemon-reload'

fan-enable:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl enable --now fan-control.service'

fan-disable:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl disable --now fan-control.service'

fan-restart:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl restart fan-control.service'

fan-status:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo systemctl status fan-control.service --no-pager'

fan-logs:
  ssh {{blade_user}}@{{blade_hostname}} 'sudo journalctl -u fan-control.service -n 100 --no-pager'

fan-set-profile:
  ssh {{blade_user}}@{{blade_hostname}} "printf '%s\n' '{{fan_profile}}' | sudo tee /etc/fan-control/profile >/dev/null && sudo systemctl restart fan-control.service"

fan-read-rpm:
  ssh {{blade_user}}@{{blade_hostname}} '~/.nix-profile/bin/fan-read-rpm'

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
