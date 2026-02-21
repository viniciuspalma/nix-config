{
  lib,
  pkgs,
  self,
  ...
}: {
  home.packages = [
    self.packages.${pkgs.system}.zeroclaw
    pkgs.sqlite
  ];

  home.shellAliases = {
    zc = "zeroclaw";
  };

  home.file.".zeroclaw/config.template.toml".source = ./zeroclaw/config.template.toml;
  home.file.".zeroclaw/workspace/skills/gmailctl".source = ../skills/gmailctl;

  home.activation.zeroclawRestartService = lib.hm.dag.entryAfter ["reloadSystemd"] ''
    if [ -f "$HOME/.config/systemd/user/zeroclaw.service" ]; then
      if ${pkgs.systemd}/bin/systemctl --user is-active --quiet zeroclaw.service; then
        ${pkgs.systemd}/bin/systemctl --user restart zeroclaw.service || true
      fi
    fi
  '';
}
