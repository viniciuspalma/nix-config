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
}
